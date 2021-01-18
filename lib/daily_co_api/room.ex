defmodule DailyCoAPI.Room do
  alias DailyCoAPI.{HTTP, Params}

  def list() do
    {:ok, http_response} = HTTP.client().get(list_all_url(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
    end
  end

  def get(room_name) do
    {:ok, http_response} = HTTP.client().get(room_url(room_name), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_room_data()}
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 404} -> {:error, :not_found}
      %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
    end
  end

  @valid_create_params [:name, :exp]

  def create(params \\ %{})

  def create(params) when is_list(params), do: params |> Map.new() |> create()

  def create(params) when is_map(params) do
    case check_for_valid_params(params) do
      {:ok, valid_params} ->
        json_params =
          valid_params |> convert_to_proper_format() |> Params.filter_out_nil_keys() |> Params.default_to_empty_map() |> Jason.encode!()

        {:ok, http_response} = HTTP.client().post(create_room_url(), json_params, HTTP.headers())

        case http_response do
          %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_room_data()}
          %{status_code: 400, body: json_response} -> json_response |> process_400_error()
          %{status_code: 401} -> {:error, :unauthorized}
          %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
        end

      error ->
        error
    end
  end

  def delete(room_name) do
    {:ok, http_response} = HTTP.client().delete(delete_room_url(room_name), HTTP.headers())

    case http_response do
      %{status_code: 200} -> :ok
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 404} -> {:error, :not_found}
      %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
    end
  end

  defp list_all_url(), do: HTTP.daily_co_api_endpoint() <> "rooms"
  defp create_room_url(), do: HTTP.daily_co_api_endpoint() <> "rooms"
  defp room_url(room_name), do: HTTP.daily_co_api_endpoint() <> "rooms/#{room_name}"
  defp delete_room_url(room_name), do: HTTP.daily_co_api_endpoint() <> "rooms/" <> room_name

  defp check_for_valid_params(params) do
    with {:ok, params} <- Params.check_for_valid_params(params, @valid_create_params),
         {:ok, params} <- check_for_valid_room_name(params) do
      {:ok, params}
    else
      error ->
        error
    end
  end

  def check_for_valid_room_name(params) do
    room_name = params[:name]

    if room_name && Regex.match?(~r/[^A-Za-z0-9_\-]/, room_name) do
      {:error, :invalid_room_name, "#{room_name} contains invalid characters (room names can contain A-Z, a-z, 0-9, '-', and '_')"}
    else
      {:ok, params}
    end
  end

  defp extract_fields(json) do
    room_data = for room_json <- json["data"], into: [], do: extract_room_data(room_json)

    %{
      total_count: json["total_count"],
      rooms: room_data
    }
  end

  defp convert_to_proper_format(params) do
    %{
      name: params[:name],
      properties: %{exp: params[:exp]}
    }
  end

  defp extract_room_data(room_json) do
    %{
      id: room_json["id"],
      name: room_json["name"],
      api_created: room_json["api_created"],
      privacy: room_json["privacy"],
      url: room_json["url"],
      created_at: room_json["created_at"] |> NaiveDateTime.from_iso8601!(),
      config: extract_config_data(room_json["config"])
    }
  end

  defp extract_config_data(config_json) do
    case config_json["start_video_off"] do
      nil -> %{}
      start_video_off -> %{start_video_off: start_video_off}
    end
  end

  defp process_400_error(json_response) do
    response = json_response |> Jason.decode!()
    info = response["info"]

    if(Regex.match?(~r/^a room named .* already exists$/, info)) do
      {:error, :room_already_exists, info}
    else
      {:error, :invalid_data, response}
    end
  end
end

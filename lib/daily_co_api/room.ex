defmodule DailyCoAPI.Room do
  alias DailyCoAPI.HTTP

  def list_all() do
    {:ok, http_response} = HTTP.client().get(list_all_url(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  def get(room_name) do
    {:ok, http_response} = HTTP.client().get(room_url(room_name), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_room_data()}
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 404} -> {:error, :not_found}
    end
  end

  defp list_all_url(), do: HTTP.daily_co_api_endpoint() <> "rooms"
  defp room_url(room_name), do: HTTP.daily_co_api_endpoint() <> "rooms/#{room_name}"

  defp extract_fields(json) do
    room_data = for room_json <- json["data"], into: [], do: extract_room_data(room_json)

    %{
      total_count: json["total_count"],
      rooms: room_data
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
end

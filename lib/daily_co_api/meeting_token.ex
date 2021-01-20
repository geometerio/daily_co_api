defmodule DailyCoAPI.MeetingToken do
  alias DailyCoAPI.{HTTP, MeetingToken, Params}

  @enforce_keys [
    :lang,
    :start_audio_off,
    :is_owner,
    :room_name,
    :start_video_off,
    :user_name
  ]

  defstruct @enforce_keys

  @valid_create_params [:exp, :is_owner, :room_name]

  @type t :: %__MODULE__{
          lang: String.t() | nil,
          start_audio_off: boolean() | nil,
          is_owner: boolean() | nil,
          room_name: String.t(),
          start_video_off: boolean() | nil,
          user_name: String.t() | nil
        }

  @spec create(keyword() | map()) ::
          {:ok, String.t()}
          | {:error, :unauthorized}
          | {:error, :invalid_data | :invalid_params | :server_error, map()}

  def create(params) when is_list(params), do: params |> Map.new() |> create()

  def create(params) when is_map(params) do
    with {:ok, valid_params} <- params |> Params.check_for_valid_params(@valid_create_params),
         {:ok, http_response} <- HTTP.client().post(create_meeting_token_url(), %{properties: valid_params} |> Jason.encode!(), HTTP.headers()) do
      case http_response do
        %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> Map.get("token")}
        %{status_code: 400, body: json_response} -> {:error, :invalid_data, json_response |> Jason.decode!()}
        %{status_code: 401} -> {:error, :unauthorized}
        %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
      end
    else
      {:error, %HTTPoison.Error{reason: error_message}} ->
        {:error, :http_error, error_message}

      error ->
        error
    end
  end

  @spec validate(String.t()) ::
          {:ok, MeetingToken.t()}
          | {:error, :invalid_meeting_token | :unauthorized}
          | {:error, :server_error, map()}
          | {:error, :http_error, String.t()}
  def validate(meeting_token) do
    case HTTP.client().get(validate_meeting_token_url(meeting_token), HTTP.headers()) do
      {:ok, http_response} ->
        case http_response do
          %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> validated_meeting_token()}
          %{status_code: 400} -> {:error, :invalid_meeting_token}
          %{status_code: 401} -> {:error, :unauthorized}
          %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
        end

      {:error, %HTTPoison.Error{reason: error_message}} ->
        {:error, :http_error, error_message}
    end
  end

  defp create_meeting_token_url(), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens"
  defp validate_meeting_token_url(meeting_token), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens/#{meeting_token}"

  defp validated_meeting_token(meeting_token_json) do
    Params.raise_if_extra_keys_in_json(meeting_token_json, @enforce_keys)

    %__MODULE__{
      lang: meeting_token_json["lang"],
      start_audio_off: meeting_token_json["start_audio_off"],
      is_owner: meeting_token_json["is_owner"],
      room_name: meeting_token_json["room_name"],
      start_video_off: meeting_token_json["start_video_off"],
      user_name: meeting_token_json["user_name"]
    }
  end
end

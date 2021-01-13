defmodule DailyCoAPI.MeetingToken do
  alias DailyCoAPI.HTTP

  def create(params) do
    json_params = %{properties: params} |> Jason.encode!()
    {:ok, http_response} = HTTP.client().post(create_meeting_token_url(), json_params, HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> Map.get("token")}
      %{status_code: 400, body: json_response} -> {:error, :invalid_data, json_response |> Jason.decode!()}
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
    end
  end

  def validate(meeting_token) do
    {:ok, http_response} = HTTP.client().get(validate_meeting_token_url(meeting_token), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> validated_meeting_token()}
      %{status_code: 400} -> {:error, :invalid_meeting_token}
      %{status_code: 401} -> {:error, :unauthorized}
      %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
    end
  end

  defp create_meeting_token_url(), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens"
  defp validate_meeting_token_url(meeting_token), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens/#{meeting_token}"

  defp validated_meeting_token(meeting_token_json) do
    %{
      lang: meeting_token_json["lang"],
      start_audio_off: meeting_token_json["start_audio_off"],
      is_owner: meeting_token_json["is_owner"],
      room_name: meeting_token_json["room_name"],
      start_video_off: meeting_token_json["start_video_off"],
      user_name: meeting_token_json["user_name"]
    }
  end
end

defmodule DailyCoAPI.MeetingToken do
  alias DailyCoAPI.HTTP

  def create(params) do
    {:ok, http_response} = HTTP.client().post(create_meeting_token_url(), params |> Jason.encode!(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_meeting_token()}
      %{status_code: 400, body: json_response} -> {:error, :invalid_data, json_response |> Jason.decode!()}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  def validate(meeting_token) do
    {:ok, http_response} = HTTP.client().get(validate_meeting_token_url(meeting_token), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> validated_meeting_token()}
      %{status_code: 400} -> {:error, :invalid_meeting_token}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  defp create_meeting_token_url(), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens"
  defp validate_meeting_token_url(meeting_token), do: HTTP.daily_co_api_endpoint() <> "meeting-tokens/#{meeting_token}"

  # TODO: combine these two functions!!!
  defp extract_meeting_token(meeting_token_json) do
    %{
      close_tab_on_exit: meeting_token_json["close_tab_on_exit"],
      enable_recording: meeting_token_json["enable_recording"],
      exp: meeting_token_json["exp"],
      is_owner: meeting_token_json["is_owner"],
      room_name: meeting_token_json["room_name"],
      start_video_off: meeting_token_json["start_video_off"],
      user_name: meeting_token_json["user_name"]
    }
  end

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

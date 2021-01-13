defmodule DailyCoAPI.MeetingTokenTest do
  use ExUnit.Case, async: true
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.MeetingToken
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  describe "create/1" do
    test "success" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        assert body == "{\"room_name\":\"my-new-room\"}"
        json_response = File.read!("test/daily_co_api/meeting_token_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      params = %{room_name: "my-new-room"}

      {:ok, meeting_token} = MeetingToken.create(params)
      assert meeting_token == expected_meeting_token()
    end

    test "gives an error if invalid parameters are given" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        assert body == "{\"invalid\":\"parameter\"}"
        json_response = "{\"error\":\"invalid-request-error\",\"info\":\"unknown parameter 'invalid'\"}"
        {:ok, %HTTPoison.Response{status_code: 400, body: json_response}}
      end)

      params = %{invalid: "parameter"}

      response = MeetingToken.create(params)
      assert response == {:error, :invalid_data, %{"error" => "invalid-request-error", "info" => "unknown parameter 'invalid'"}}
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = MeetingToken.create(%{})
    end

    defp expected_meeting_token() do
      %{
        exp: 1_548_633_621,
        room_name: "my-new-room",
        user_name: "A. User",
        is_owner: true,
        close_tab_on_exit: true,
        enable_recording: "cloud",
        start_video_off: true
      }
    end
  end

  describe "validate/1" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/valid-meeting-token"
        assert_correct_headers(headers)
        json_response = File.read!("test/daily_co_api/validated_meeting_token_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, meeting_token} = MeetingToken.validate("valid-meeting-token")
      assert meeting_token == expected_valid_meeting_token()
    end

    test "gives an error if the meeting token is invalid" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/invalid-meeting-token"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 400, body: "{}"}}
      end)

      response = MeetingToken.validate("invalid-meeting-token")
      assert response == {:error, :invalid_meeting_token}
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/valid-meeting-token"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = MeetingToken.validate("valid-meeting-token")
    end

    defp expected_valid_meeting_token() do
      %{
        room_name: "EevVrrxee4JBxKzmKkjC",
        is_owner: true,
        user_name: "host",
        start_video_off: false,
        start_audio_off: true,
        lang: "en"
      }
    end
  end
end

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
        assert body == ~S|{"properties":{"room_name":"my-new-room"}}|
        json_response = ~S|{"token": "abcdefg1234"}|
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      params = %{room_name: "my-new-room"}

      {:ok, meeting_token} = MeetingToken.create(params)
      assert meeting_token == "abcdefg1234"
    end

    test "success - works with a keyword list for arguments" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        assert body == ~S|{"properties":{"exp":12345,"is_owner":true,"room_name":"my-new-room"}}|
        json_response = ~S|{"token": "abcdefg1234"}|
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, meeting_token} = MeetingToken.create(room_name: "my-new-room", exp: 12345, is_owner: true)
      assert meeting_token == "abcdefg1234"
    end

    test "gives an error if invalid parameters are given" do
      response = MeetingToken.create(invalid: "parameter")
      assert response == {:error, :invalid_params, [:invalid]}
    end

    test "gives an error if invalid data is provided" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        assert body == ~s|{"properties":{"exp":"not an integer"}}|

        json_response = ~s|{"error":"invalid-request-error","info":"exp was 'not an int' but should be a number of seconds since the unix epoch"}|

        {:ok, %HTTPoison.Response{status_code: 400, body: json_response}}
      end)

      response = MeetingToken.create(exp: "not an integer")

      assert response ==
               {:error, :invalid_data,
                %{
                  "error" => "invalid-request-error",
                  "info" => "exp was 'not an int' but should be a number of seconds since the unix epoch"
                }}
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = MeetingToken.create(%{})
    end

    test "server error" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        json_response = "{\"error\":\"server-error\"}"
        {:ok, %HTTPoison.Response{status_code: 500, body: json_response}}
      end)

      {:error, :server_error, error_message} = MeetingToken.create(%{room_name: "my-room-name"})
      assert error_message == "server-error"
    end

    test "http error" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = MeetingToken.create(%{room_name: "my-room-name"})
      assert response == {:error, :http_error, :nxdomain}
    end
  end

  describe "validate/1" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/valid-meeting-token"
        assert_correct_headers(headers)
        json_response = File.read!("test/fixtures/validated_meeting_token_response.json")
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

    test "gives a server error if something goes wrong" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/invalid-meeting-token"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
      end)

      response = MeetingToken.validate("invalid-meeting-token")
      assert response == {:error, :server_error, "server-error"}
    end

    test "gives an http error if something goes wrong at the http level" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/meeting-tokens/invalid-meeting-token"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = MeetingToken.validate("invalid-meeting-token")
      assert response == {:error, :http_error, :nxdomain}
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
      %MeetingToken{
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

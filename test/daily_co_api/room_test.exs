defmodule DailyCoAPI.RoomTest do
  use ExUnit.Case, async: true
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.Room
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  describe "list/0" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        json_response = File.read!("test/fixtures/room_list_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.list()

      assert room_data == expected_room_list_response()
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.list()
    end

    test "gives a server error if something goes wrong" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
      end)

      response = Room.list()
      assert response == {:error, :server_error, "server-error"}
    end

    test "gives a server error if something goes wrong at the http level" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = Room.list()
      assert response == {:error, :http_error, :nxdomain}
    end

    defp expected_room_list_response() do
      %{
        total_count: 2,
        rooms: [
          %Room{
            id: "5e3cf703-5547-47d6-a371-37b1f0b4427f",
            name: "w2pp2cf4kltgFACPKXmX",
            api_created: false,
            privacy: "public",
            url: "https://api-demo.daily.co/w2pp2cf4kltgFACPKXmX",
            created_at: ~N[2019-01-26T09:01:22.000Z],
            config: %{start_video_off: true}
          },
          %Room{
            id: "d61cd7b2-a273-42b4-89bd-be763fd562c1",
            name: "hello",
            api_created: false,
            privacy: "public",
            url: "https://your-domain.daily.co/hello",
            created_at: ~N[2019-01-25T23:49:42.000Z],
            config: %{}
          }
        ]
      }
    end
  end

  describe "get/1" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        json_response = File.read!("test/fixtures/room_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.get("my-room")
      assert room_data == expected_room_data()
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.get("my-room")
    end

    test "not found" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/does-not-exist"
        assert_correct_headers(headers)

        {:ok,
         %HTTPoison.Response{
           status_code: 404,
           body: "{\"error\":\"not-found\",\"info\":\"room does-not-exist  not found\"}"
         }}
      end)

      {:error, :not_found} = Room.get("does-not-exist")
    end

    test "gives a server error if something goes wrong" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
      end)

      response = Room.get("my-room")
      assert response == {:error, :server_error, "server-error"}
    end

    test "gives an http error if something goes wrong at the http level" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = Room.get("my-room")
      assert response == {:error, :http_error, :nxdomain}
    end

    defp expected_room_data() do
      %Room{
        api_created: false,
        config: %{start_video_off: true},
        created_at: ~N[2019-01-26 09:01:22.000],
        id: "d61cd7b2-a273-42b4-89bd-be763fd562c1",
        name: "my-room",
        privacy: "public",
        url: "https://api-demo.daily.co/w2pp2cf4kltgFACPKXmX"
      }
    end
  end

  describe "create/1" do
    test "success" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == "{\"name\":\"my-new-room\"}"
        json_response = File.read!("test/fixtures/room_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      params = %{name: "my-new-room"}

      {:ok, room_data} = Room.create(params)
      assert room_data == expected_room_data()
    end

    test "success - works with no params" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == "{}"
        json_response = File.read!("test/fixtures/room_create_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.create()
      assert room_data == expected_room_data_on_create()
    end

    test "gives an error if invalid parameters are given" do
      params = %{invalid: "parameter"}

      response = Room.create(params)
      assert response == {:error, :invalid_params, [:invalid]}
    end

    test "gives an error if the room name plus domain name is longer than 41 characters" do
      # The test domain name is 11 characters long
      room_name = "123456789012345678901234567890"
      room_name_too_long = room_name <> "1"

      response = Room.create(name: room_name_too_long)
      assert response == {:error, :room_name_too_long, "domain name plus room name exceeds 41 character limit"}
    end

    test "gives an error if an invalid room name is given" do
      response = Room.create(name: "invalid#room#name")

      assert response ==
               {:error, :invalid_room_name, "invalid#room#name contains invalid characters (room names can contain A-Z, a-z, 0-9, '-', and '_')"}
    end

    test "gives an error if invalid data is provided" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == ~s|{"properties":{"exp":"not an integer"}}|

        json_response = ~s|{"error":"invalid-request-error","info":"exp was 'not an int' but should be a number of seconds since the unix epoch"}|

        {:ok, %HTTPoison.Response{status_code: 400, body: json_response}}
      end)

      response = Room.create(exp: "not an integer")

      assert response ==
               {:error, :invalid_data,
                %{
                  "error" => "invalid-request-error",
                  "info" => "exp was 'not an int' but should be a number of seconds since the unix epoch"
                }}
    end

    test "gives an error if the room already exists" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == ~s|{"name":"foo"}|

        json_response = ~s|{"error":"invalid-request-error","info":"a room named foo already exists"}|

        {:ok, %HTTPoison.Response{status_code: 400, body: json_response}}
      end)

      response = Room.create(name: "foo")

      assert response == {:error, :room_already_exists, %{room_name: "foo"}}
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.create(%{})
    end

    test "gives a server error if something goes wrong" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
      end)

      response = Room.create()
      assert response == {:error, :server_error, "server-error"}
    end

    test "gives an http error if something goes wrong at the http level" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = Room.create()
      assert response == {:error, :http_error, :nxdomain}
    end

    test "success - changes params into the proper format required by daily.co" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == ~s|{"name":"my-new-room","properties":{"exp":1000,"start_audio_off":true,"start_video_off":true}}|
        json_response = File.read!("test/fixtures/room_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      params = %{name: "my-new-room", exp: 1000, start_audio_off: true, start_video_off: true}

      {:ok, room_data} = Room.create(params)
      assert room_data == expected_room_data()
    end

    test "success - accepts a keyword list of params" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == ~s|{"name":"my-new-room","properties":{"exp":1000}}|
        json_response = File.read!("test/fixtures/room_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.create(name: "my-new-room", exp: 1000)
      assert room_data == expected_room_data()
    end

    defp expected_room_data_on_create() do
      %Room{
        api_created: true,
        config: %{start_video_off: true},
        created_at: ~N[2019-01-26 09:01:22.000],
        id: "d61cd7b2-a273-42b4-89bd-be763fd562c1",
        name: "my-new-room",
        privacy: "public",
        url: "https://api-demo.daily.co/my-new-room"
      }
    end
  end

  describe "delete/1" do
    test "success" do
      expect(HTTPoisonMock, :delete, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/some-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 200, body: ""}}
      end)

      assert Room.delete("some-room") == :ok
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :delete, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/some-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.delete("some-room")
    end

    test "room does not exist" do
      expect(HTTPoisonMock, :delete, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/nonexistent-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
      end)

      {:error, :not_found} = Room.delete("nonexistent-room")
    end

    test "gives a server error if something goes wrong" do
      expect(HTTPoisonMock, :delete, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
      end)

      response = Room.delete("my-room")
      assert response == {:error, :server_error, "server-error"}
    end

    test "gives an http error if something goes wrong at the http level" do
      expect(HTTPoisonMock, :delete, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms/my-room"
        assert_correct_headers(headers)
        {:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}
      end)

      response = Room.delete("my-room")
      assert response == {:error, :http_error, :nxdomain}
    end
  end

  describe "check_for_valid_room_name/1" do
    test "returns ok if the room name has only the allowed characters" do
      assert Room.check_for_valid_room_name(%{name: "valid-room-name"}) == {:ok, %{name: "valid-room-name"}}
    end

    test "returns an error if the room name has characters that are not allowed" do
      assert Room.check_for_valid_room_name(%{name: "invalid#name"}) ==
               {:error, :invalid_room_name, "invalid#name contains invalid characters (room names can contain A-Z, a-z, 0-9, '-', and '_')"}
    end

    test "returns an error if the room name plus the domain name is longer than 41 characters" do
      # The test domain name is 11 characters long
      room_name = "123456789012345678901234567890"
      assert Room.check_for_valid_room_name(%{name: room_name}) == {:ok, %{name: room_name}}

      room_name_too_long = room_name <> "1"

      assert Room.check_for_valid_room_name(%{name: room_name_too_long}) ==
               {:error, :room_name_too_long, "domain name plus room name exceeds 41 character limit"}
    end
  end

  describe "max_allowed_room_name_length/0" do
    test "returns the maximum allowed room name length" do
      # Note that the test domain is 11 characters long.
      assert Room.max_allowed_room_name_length() == 30
    end
  end
end

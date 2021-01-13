defmodule DailyCoAPI.RoomTest do
  use ExUnit.Case, async: true
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.Room
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  describe "list_all/0" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        json_response = File.read!("test/daily_co_api/room_list_all_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.list_all()

      assert room_data == expected_room_list_all_response()
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.list_all()
    end

    defp expected_room_list_all_response() do
      %{
        total_count: 2,
        rooms: [
          %{
            id: "5e3cf703-5547-47d6-a371-37b1f0b4427f",
            name: "w2pp2cf4kltgFACPKXmX",
            api_created: false,
            privacy: "public",
            url: "https://api-demo.daily.co/w2pp2cf4kltgFACPKXmX",
            created_at: ~N[2019-01-26T09:01:22.000Z],
            config: %{start_video_off: true}
          },
          %{
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
        json_response = File.read!("test/daily_co_api/room_response.json")
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

    defp expected_room_data() do
      %{
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
        json_response = File.read!("test/daily_co_api/room_response.json")
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
        json_response = File.read!("test/daily_co_api/room_create_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, room_data} = Room.create()
      assert room_data == expected_room_data_on_create()
    end

    test "gives an error if invalid parameters are given" do
      expect(HTTPoisonMock, :post, fn url, body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        assert body == "{\"invalid\":\"parameter\"}"
        json_response = "{\"error\":\"invalid-request-error\",\"info\":\"unknown parameter 'invalid'\"}"
        {:ok, %HTTPoison.Response{status_code: 400, body: json_response}}
      end)

      params = %{invalid: "parameter"}

      response = Room.create(params)
      assert response == {:error, :invalid_data, %{"error" => "invalid-request-error", "info" => "unknown parameter 'invalid'"}}
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :post, fn url, _body, headers ->
        assert url == "https://api.daily.co/v1/rooms"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = Room.create(%{})
    end

    defp expected_room_data_on_create() do
      %{
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
end

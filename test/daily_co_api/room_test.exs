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
end

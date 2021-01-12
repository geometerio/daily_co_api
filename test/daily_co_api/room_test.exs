defmodule DailyCoAPI.RoomTest do
  use ExUnit.Case, async: true
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.Room
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  test "list_all/0" do
    expect(HTTPoisonMock, :get, fn url, headers ->
      assert url == "https://api.daily.co/v1/rooms"
      assert_correct_headers(headers)
      json_response = File.read!("test/daily_co_api/room_list_all_response.json")
      {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
    end)

    {:ok, room_data} = Room.list_all()

    expected = %{
      total_count: 2
    }

    assert room_data == expected
  end
end

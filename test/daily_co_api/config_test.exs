defmodule DailyCoAPI.ConfigTest do
  use ExUnit.Case
  doctest DailyCoAPI

  alias DailyCoAPI.Config
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  test "get/0" do
    expect(HTTPoisonMock, :get, fn url, headers ->
      assert url == "https://api.daily.co/v1/"
      [header] = headers
      assert header == {:Authorization, "Bearer "}
      json_response = File.read!("test/daily_co_api/config_response.json")
      {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
    end)

    {:ok, config} = Config.get()

    expected = %{
      domain_name: "your-domain"
    }

    assert config == expected
  end
end

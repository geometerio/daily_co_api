defmodule DailyCoAPI.DomainConfigTest do
  use ExUnit.Case
  doctest DailyCoAPI

  alias DailyCoAPI.DomainConfig
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  test "get/0" do
    expect(HTTPoisonMock, :get, fn url, headers ->
      assert url == "https://api.daily.co/v1/"
      [{:Authorization, auth}] = headers
      assert Regex.match?(~r/Bearer \w{64,}/, auth)
      json_response = File.read!("test/daily_co_api/domain_config_response.json")
      {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
    end)

    {:ok, config} = DomainConfig.get()

    expected = %{
      domain_name: "your-domain"
    }

    assert config == expected
  end
end

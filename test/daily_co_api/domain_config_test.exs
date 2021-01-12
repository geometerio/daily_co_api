defmodule DailyCoAPI.DomainConfigTest do
  use ExUnit.Case
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.DomainConfig
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  test "get/0" do
    expect(HTTPoisonMock, :get, fn url, headers ->
      assert url == "https://api.daily.co/v1/"
      assert_correct_headers(headers)
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

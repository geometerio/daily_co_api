defmodule DailyCoAPI.DomainConfigTest do
  use ExUnit.Case
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.DomainConfig
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  describe "get/0" do
    test "success" do
      expect(
        HTTPoisonMock,
        :get,
        fn url, headers ->
          assert url == "https://api.daily.co/v1/"
          assert_correct_headers(headers)
          json_response = File.read!("test/daily_co_api/domain_config_response.json")
          {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
        end
      )

      {:ok, config} = DomainConfig.get()

      expected = %{
        domain_name: "your-domain"
      }

      assert config == expected
    end

    test "unauthorized" do
      expect(
        HTTPoisonMock,
        :get,
        fn url, headers ->
          assert url == "https://api.daily.co/v1/"
          assert_correct_headers(headers)
          {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
        end
      )

      {:error, :unauthorized} = DomainConfig.get()
    end
  end
end

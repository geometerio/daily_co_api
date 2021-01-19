defmodule DailyCoAPI.DomainConfigTest do
  use ExUnit.Case
  import DailyCoAPI.TestSupport.Assertions

  alias DailyCoAPI.DomainConfig
  alias DailyCoAPI.HTTPoisonMock

  import Mox
  setup :verify_on_exit!

  describe "get/0" do
    test "success" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/"
        assert_correct_headers(headers)
        json_response = File.read!("test/daily_co_api/domain_config_response.json")
        {:ok, %HTTPoison.Response{status_code: 200, body: json_response}}
      end)

      {:ok, config} = DomainConfig.get()

      assert config == expected_config()
    end

    test "unauthorized" do
      expect(HTTPoisonMock, :get, fn url, headers ->
        assert url == "https://api.daily.co/v1/"
        assert_correct_headers(headers)
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      {:error, :unauthorized} = DomainConfig.get()
    end
  end

  test "gives a server error if something goes wrong" do
    expect(HTTPoisonMock, :get, fn url, headers ->
      assert url == "https://api.daily.co/v1/"
      assert_correct_headers(headers)
      {:ok, %HTTPoison.Response{status_code: 500, body: "{\"error\":\"server-error\"}"}}
    end)

    response = DomainConfig.get()
    assert response == {:error, :server_error, "server-error"}
  end

  defp expected_config() do
    %{
      domain_name: "your-domain",
      config: %DomainConfig{
        hide_daily_branding: true,
        redirect_on_meeting_exit: "",
        meeting_join_hook: "",
        hipaa: false,
        intercom_auto_record: false,
        intercom_manual_record: "",
        sfu_impl: "s",
        signaling_impl: "ks",
        sfu_switchover: nil,
        switchover_impl: nil,
        lang: nil,
        callstats: nil,
        max_api_rooms: nil,
        webhook_meeting_end: nil,
        max_live_streams: 2,
        enable_daily_logger: true
      }
    }
  end
end

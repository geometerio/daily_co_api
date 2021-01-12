defmodule DailyCoAPI.DomainConfig do
  alias DailyCoAPI.HTTP

  def get() do
    {:ok, http_response} = HTTP.client().get(domain_config_url(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  defp domain_config_url(), do: HTTP.daily_co_api_endpoint()

  defp extract_fields(json) do
    %{
      domain_name: json["domain_name"],
      config: extract_config_fields(json["config"])
    }
  end

  defp extract_config_fields(config_json) do
    %{
      callstats: config_json["callstats"],
      enable_daily_logger: config_json["enable_daily_logger"],
      hide_daily_branding: config_json["hide_daily_branding"],
      hipaa: config_json["hipaa"],
      intercom_auto_record: config_json["intercom_auto_record"],
      intercom_manual_record: config_json["intercom_manual_record"],
      lang: config_json["lang"],
      max_api_rooms: config_json["max_api_rooms"],
      max_live_streams: config_json["max_live_streams"] |> String.to_integer(),
      meeting_join_hook: config_json["meeting_join_hook"],
      redirect_on_meeting_exit: config_json["redirect_on_meeting_exit"],
      sfu_impl: config_json["sfu_impl"],
      sfu_switchover: config_json["sfu_switchover"],
      signaling_impl: config_json["signaling_impl"],
      switchover_impl: config_json["switchover_impl"],
      webhook_meeting_end: config_json["webhook_meeting_end"]
    }
  end
end

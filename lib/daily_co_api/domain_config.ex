defmodule DailyCoAPI.DomainConfig do
  alias DailyCoAPI.{
    DomainConfig,
    HTTP,
    Params
  }

  @enforce_keys [
    :enable_daily_logger,
    :hide_daily_branding,
    :hipaa,
    :intercom_auto_record,
    :intercom_manual_record,
    :max_live_streams,
    :meeting_join_hook,
    :redirect_on_meeting_exit,
    :sfu_impl,
    :signaling_impl
  ]
  @optional_keys [
    :callstats,
    :lang,
    :max_api_rooms,
    :sfu_switchover,
    :switchover_impl,
    :webhook_meeting_end
  ]

  defstruct @enforce_keys ++ @optional_keys

  @type t :: %__MODULE__{
          callstats: nil | String.t(),
          enable_daily_logger: boolean(),
          hide_daily_branding: boolean(),
          hipaa: boolean(),
          intercom_auto_record: boolean(),
          intercom_manual_record: String.t(),
          lang: nil | String.t(),
          max_api_rooms: nil | integer(),
          max_live_streams: nil | integer(),
          meeting_join_hook: String.t(),
          redirect_on_meeting_exit: String.t(),
          sfu_impl: String.t(),
          sfu_switchover: nil | integer(),
          signaling_impl: String.t(),
          switchover_impl: nil | String.t(),
          webhook_meeting_end: nil | String.t()
        }

  @spec get ::
          {:ok, %{config: DomainConfig.t(), domain_name: String.t()}}
          | {:error, :unauthorized}
          | {:error, :server_error, map()}
          | {:error, :http_error, String.t()}
  def get() do
    case HTTP.client().get(domain_config_url(), HTTP.headers()) do
      {:ok, http_response} ->
        case http_response do
          %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
          %{status_code: 401} -> {:error, :unauthorized}
          %{status_code: 500, body: json_response} -> {:error, :server_error, json_response |> Jason.decode!() |> Map.get("error")}
        end

      {:error, %HTTPoison.Error{reason: error_message}} ->
        {:error, :http_error, error_message}
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
    Params.raise_if_extra_keys_in_json(config_json, @enforce_keys ++ @optional_keys)

    %__MODULE__{
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

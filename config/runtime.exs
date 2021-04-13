import Config


if config_env() != :test do
  config :daily_co_api, api_key: System.get_env("DAILY_CO_API_KEY")
  config :daily_co_api, domain: System.get_env("DAILY_CO_DOMAIN")
end

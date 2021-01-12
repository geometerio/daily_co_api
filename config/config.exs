import Config

config :daily_co_api,
  http_client: HTTPoison,
  api_endpoint: "https://api.daily.co/v1/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import Config

config :daily_co_api,
  api_key: "testapikey",
  domain: "test-domain",
  http_client: DailyCoAPI.HTTPoisonMock

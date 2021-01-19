import Config

config :daily_co_api,
  http_client: DailyCoAPI.HTTPoisonMock,
  domain: "test-domain"

Mox.defmock(DailyCoAPI.HTTPoisonMock, for: HTTPoison.Base)
Application.put_env(:daily_co_api, :api_key, System.get_env("DAILY_CO_API_KEY"))

ExUnit.start()

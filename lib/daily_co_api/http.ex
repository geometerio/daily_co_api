defmodule DailyCoAPI.HTTP do
  @http_client Application.compile_env!(:daily_co_api, :http_client)
  @daily_co_api_endpoint Application.compile_env!(:daily_co_api, :api_endpoint)

  def headers(), do: [Authorization: "Bearer #{daily_co_api_key()}"]
  def client(), do: @http_client
  def daily_co_api_endpoint(), do: @daily_co_api_endpoint

  defp daily_co_api_key(), do: Application.fetch_env!(:daily_co_api, :api_key)
end

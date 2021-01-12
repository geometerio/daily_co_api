defmodule DailyCoAPI.HTTP do
  def headers(), do: [Authorization: "Bearer #{daily_co_api_key()}"]

  defp daily_co_api_key(), do: Application.fetch_env!(:daily_co_api, :api_key)
end

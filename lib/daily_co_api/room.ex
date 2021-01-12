defmodule DailyCoAPI.Room do
  alias DailyCoAPI.HTTP

  def list_all() do
    {:ok, %{body: response}} = HTTP.client().get(list_all_url(), HTTP.headers())
    {:ok, response |> Jason.decode!() |> extract_fields()}
  end

  defp list_all_url(), do: HTTP.daily_co_api_endpoint() <> "rooms"

  defp extract_fields(json) do
    %{total_count: json["total_count"]}
  end
end

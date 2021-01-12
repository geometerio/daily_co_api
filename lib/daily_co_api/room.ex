defmodule DailyCoAPI.Room do
  @http_client Application.compile_env!(:daily_co_api, :http_client)
  @daily_co_api_endpoint Application.compile_env!(:daily_co_api, :api_endpoint)

  def list_all() do
    {:ok, %{body: response}} = @http_client.get(@daily_co_api_endpoint, headers())
    {:ok, response |> Jason.decode!() |> extract_fields()}
  end

  defp headers(), do: ["Authorization: Bearer #{daily_co_api_key()}"]
  defp daily_co_api_key(), do: Application.fetch_env!(:daily_co_api, :api_key)

  defp extract_fields(json) do
    %{total_count: json["total_count"]}
  end
end

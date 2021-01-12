defmodule DailyCoAPI.Config do
  @http_client Application.compile_env!(:daily_co_api, :http_client)
  @daily_co_api_endpoint Application.compile_env!(:daily_co_api, :api_endpoint)

  def get() do
    {:ok, %{body: response}} = @http_client.get(get_config_url(), headers())
    {:ok, response |> Jason.decode!() |> extract_fields()}
  end

  defp get_config_url(), do: @daily_co_api_endpoint
  defp headers(), do: [Authorization: "Bearer #{daily_co_api_key()}"]
  defp daily_co_api_key(), do: Application.fetch_env!(:daily_co_api, :api_key)

  defp extract_fields(json) do
    %{domain_name: json["domain_name"]}
  end
end

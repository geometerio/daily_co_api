defmodule DailyCoAPI.Config do
  @http_client Application.compile_env!(:daily_co_api, :http_client)
  @daily_co_api_endpoint Application.compile_env!(:daily_co_api, :api_endpoint)

  alias DailyCoAPI.HTTP

  def get() do
    {:ok, %{body: response}} = @http_client.get(get_config_url(), HTTP.headers())
    {:ok, response |> Jason.decode!() |> extract_fields()}
  end

  defp get_config_url(), do: @daily_co_api_endpoint

  defp extract_fields(json) do
    %{domain_name: json["domain_name"]}
  end
end

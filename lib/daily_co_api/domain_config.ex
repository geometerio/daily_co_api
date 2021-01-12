defmodule DailyCoAPI.DomainConfig do
  alias DailyCoAPI.HTTP

  def get() do
    {:ok, %{body: response}} = HTTP.client().get(domain_config_url(), HTTP.headers())
    {:ok, response |> Jason.decode!() |> extract_fields()}
  end

  defp domain_config_url(), do: HTTP.daily_co_api_endpoint()

  defp extract_fields(json) do
    %{domain_name: json["domain_name"]}
  end
end

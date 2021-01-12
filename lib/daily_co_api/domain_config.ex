defmodule DailyCoAPI.DomainConfig do
  alias DailyCoAPI.HTTP

  def get() do
    {:ok, http_response} = HTTP.client().get(domain_config_url(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  defp domain_config_url(), do: HTTP.daily_co_api_endpoint()

  defp extract_fields(json) do
    %{domain_name: json["domain_name"]}
  end
end

defmodule DailyCoAPI.Room do
  alias DailyCoAPI.HTTP

  def list_all() do
    {:ok, http_response} = HTTP.client().get(list_all_url(), HTTP.headers())

    case http_response do
      %{status_code: 200, body: json_response} -> {:ok, json_response |> Jason.decode!() |> extract_fields()}
      %{status_code: 401} -> {:error, :unauthorized}
    end
  end

  defp list_all_url(), do: HTTP.daily_co_api_endpoint() <> "rooms"

  defp extract_fields(json) do
    %{total_count: json["total_count"]}
  end
end

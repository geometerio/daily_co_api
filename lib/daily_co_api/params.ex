defmodule DailyCoAPI.Params do
  def filter_out_nil_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {key, filter_out_nil_keys(value)} end)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> convert_back_to_map()
  end

  def filter_out_nil_keys(not_a_map), do: not_a_map

  def convert_back_to_map([]), do: nil
  def convert_back_to_map(non_empty_list), do: non_empty_list |> Map.new()
end

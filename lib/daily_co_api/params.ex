defmodule DailyCoAPI.Params do
  @spec filter_out_nil_keys(any()) :: map()
  def filter_out_nil_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} -> {key, filter_out_nil_keys(value)} end)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> convert_back_to_map()
  end

  def filter_out_nil_keys(not_a_map), do: not_a_map

  @spec convert_back_to_map(keyword) :: map() | nil
  def convert_back_to_map([]), do: nil
  def convert_back_to_map(non_empty_list), do: non_empty_list |> Map.new()

  @spec check_for_valid_params(map(), [atom()]) :: {:ok, map()} | {:error, :invalid_params, [atom()]}
  def check_for_valid_params(params, valid_params) do
    valid_params = MapSet.new(valid_params)
    invalid_params = params |> Map.keys() |> Enum.reject(&MapSet.member?(valid_params, &1))

    if length(invalid_params) > 0 do
      {:error, :invalid_params, invalid_params}
    else
      {:ok, params}
    end
  end

  @spec default_to_empty_map(map() | nil) :: map()
  def default_to_empty_map(nil), do: %{}
  def default_to_empty_map(anything_but_nil), do: anything_but_nil

  @spec raise_if_extra_keys_in_json(map(), [atom()]) :: nil
  def raise_if_extra_keys_in_json(json_map, struct_keys) do
    keys_from_json = json_map |> Map.keys() |> Enum.map(&String.to_atom(&1))
    difference = MapSet.new(keys_from_json) |> MapSet.difference(MapSet.new(struct_keys))

    if MapSet.size(difference) > 0 do
      extra_keys = difference |> MapSet.to_list() |> Enum.join(", ")
      raise("Extra key(s) in JSON: #{extra_keys}")
    end
  end
end

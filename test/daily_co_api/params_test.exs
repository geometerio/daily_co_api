defmodule DailyCoAPI.ParamsTest do
  use ExUnit.Case, async: true

  alias DailyCoAPI.Params

  describe "filter_out_nil_values" do
    test "removes the nil values from a map one level deep" do
      a = %{a: 1, b: nil}
      filtered = Params.filter_out_nil_keys(a)
      assert filtered == %{a: 1}
    end

    test "returns an empty map if all values are nil" do
      a = %{a: nil, b: nil}
      filtered = Params.filter_out_nil_keys(a)
      assert filtered == nil
    end

    test "removes a subkey if all values are nil" do
      a = %{a: nil, b: 2, properties: %{exp: nil}}
      filtered = Params.filter_out_nil_keys(a)
      assert filtered == %{b: 2}
    end

    test "works multi-levels deep" do
      a = %{a: nil, b: 2, properties: %{exp: nil, foo: %{bar: nil}}}
      filtered = Params.filter_out_nil_keys(a)
      assert filtered == %{b: 2}
    end

    test "works multi-levels deep - another case" do
      a = %{a: nil, b: 2, properties: %{exp: nil, foo: %{bar: "baz"}}}
      filtered = Params.filter_out_nil_keys(a)
      assert filtered == %{b: 2, properties: %{foo: %{bar: "baz"}}}
    end
  end

  describe "check_for_valid_params" do
    test "returns :ok if the params are valid" do
      valid_params = [:a, :b]

      params = %{a: 3}
      assert Params.check_for_valid_params(params, valid_params) == {:ok, %{a: 3}}
    end

    test "returns :error if the params are invalid" do
      valid_params = [:a, :b]

      params = %{c: 3}
      assert Params.check_for_valid_params(params, valid_params) == {:error, :invalid_params, [:c]}
    end
  end

  describe "default_to_empty_map/1" do
    test "returns an empty map if nil" do
      assert Params.default_to_empty_map(nil) == %{}
    end

    test "returns the argument if non-nil" do
      assert Params.default_to_empty_map(%{foo: :bar}) == %{foo: :bar}
    end
  end

  describe "raise_if_extra_keys_in_json" do
    test "does nothing if there are no extra keys in the json" do
      json_map = %{"foo" => :bar}
      struct_keys = [:foo]
      Params.raise_if_extra_keys_in_json(json_map, struct_keys)
    end

    test "raises if there are extra keys in the json" do
      json_map = %{"foo" => :bar, "not_in_struct" => "it's not there", "also_not_in_struct" => "no"}
      struct_keys = [:foo]

      assert_raise(RuntimeError, "Extra key(s) in JSON: also_not_in_struct, not_in_struct", fn ->
        Params.raise_if_extra_keys_in_json(json_map, struct_keys)
      end)
    end
  end
end

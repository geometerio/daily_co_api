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
end

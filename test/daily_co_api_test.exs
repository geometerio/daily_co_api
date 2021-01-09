defmodule DailyCoAPITest do
  use ExUnit.Case
  doctest DailyCoAPI

  test "greets the world" do
    assert DailyCoAPI.hello() == :world
  end
end

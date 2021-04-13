defmodule DailyCoAPI.TestSupport.Assertions do
  import ExUnit.Assertions

  def assert_correct_headers(headers) do
    [{:Authorization, auth}] = headers
    assert Regex.match?(~r/Bearer testapikey/, auth)
  end
end

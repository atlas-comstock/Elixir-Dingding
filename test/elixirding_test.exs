defmodule ElixirdingTest do
  use ExUnit.Case
  doctest Elixirding

  test "greets the world" do
    assert Elixirding.hello() == :world
  end
end

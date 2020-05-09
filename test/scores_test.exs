defmodule ScoresTest do
  use ExUnit.Case
  doctest Scores

  test "greets the world" do
    assert Scores.hello() == :world
  end
end

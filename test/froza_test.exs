defmodule FrozaTest do
  use ExUnit.Case
  doctest Froza

  test "greets the world" do
    assert Froza.hello() == :world
  end
end

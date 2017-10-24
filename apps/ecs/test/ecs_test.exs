defmodule EcsTest do
  use ExUnit.Case
  doctest Ecs

  test "greets the world" do
    assert Ecs.hello() == :world
  end
end

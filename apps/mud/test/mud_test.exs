defmodule MudTest do
  use ExUnit.Case
  doctest Mud

  test "greets the world" do
    assert Mud.hello() == :world
  end
end

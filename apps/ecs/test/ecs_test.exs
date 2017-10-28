defmodule EcsTest do
  alias Ecs.Entity
  alias Ecs.System.TimeSystem
  alias Ecs.Component.TimeComponent
  use ExUnit.Case
  doctest Ecs

  test "Time system increases age of mobs that are affected by time" do
    dwarf = Entity.new(TimeComponent)
    IO.inspect dwarf
    TimeSystem.process
    dwarf = Entity.reload(dwarf)
    assert List.first(dwarf.components).age == 2
  end

  test "Entity has components" do
    dwarf = Entity.new(
      components: [
        TimeComponent
      ])
    assert Entity.has_component?(dwarf, TimeComponent)
  end

  test "greets the world" do
    assert Ecs.hello() == :world
  end
end

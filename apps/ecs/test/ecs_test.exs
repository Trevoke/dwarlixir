defmodule EcsTest do
  alias Ecs.Entity
  alias Ecs.System.Time, as: TimeSys
  alias Ecs.Component.Time, as: TimeComp
  use ExUnit.Case
  doctest Ecs

  test "Initiate an area with systems" do

  end

  test "Time system increases age of mobs that are affected by time" do
    dwarf = Entity.new(TimeComp)
    TimeSys.process
    dwarf = Entity.reload(dwarf)
    assert List.first(dwarf.components).state.age == 2
  end

  test "Entity has components" do
    dwarf = Entity.new(
      components: [
        TimeComp
      ])
    assert Entity.has_component?(dwarf, TimeComp)
  end

  test "greets the world" do
    assert Ecs.hello() == :world
  end
end

defmodule EcsTest do
  alias Ecs.Entity
  alias Ecs.System.Time, as: TimeSys
  alias Ecs.Component.Time, as: TimeComp
  alias Ecs.Component.Death, as: DeathComp
  use ExUnit.Case
  doctest Ecs

  test "figures out if an entity matches an aspect" do
    aspect = Ecs.Aspect.new(with: [TimeComp], without: [DeathComp])
    dwarf = Entity.new(TimeComp)
    assert Entity.match_aspect?(dwarf, aspect)

    aspect = Ecs.Aspect.new(with: [TimeComp], without: [DeathComp])
    dwarf = Entity.new([TimeComp, DeathComp])
    assert !(Entity.match_aspect?(dwarf, aspect))
  end

  test "Time system increases age of mobs that are affected by time" do
    dwarf = Entity.new(TimeComp)
    TimeSys.process(dwarf)
    dwarf = Entity.reload(dwarf)
    assert List.first(dwarf.components).state.age == 2
  end

  test "Entity has a component" do
    dwarf = Entity.new(TimeComp)
    assert Entity.has_component?(dwarf, TimeComp)
  end

  test "Entity has components" do
    dwarf = Entity.new([TimeComp, DeathComp])
    assert Entity.has_component?(dwarf, TimeComp)
    assert Entity.has_component?(dwarf, DeathComp)
  end

  @tag skip: "Need to define API"
  test "Entity can contain other entities" do
    room = Entity.new
    dwarf = Entity.new(TimeComp)
    Entity.place(dwarf, into: room)
  end

end

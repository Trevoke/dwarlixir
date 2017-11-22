defmodule EcsTest do
  alias Ecs.{Entity, Aspect}
  alias Ecs.Component.Time, as: TimeComp
  alias Ecs.Component.Death, as: DeathComp
  use ExUnit.Case
  doctest Ecs

  test "A system can be triggered on an entity with a component" do
    defmodule PingComponent do
      use Ecs.Component
      def default_value, do: %{
            pid: self(),
            delay: :timer.seconds(3),
            message: :ping,
            schedule: :once,
            pubsub: %{}
                         }
    end
    defmodule TickSystem do
      use Ecs.System
      def aspect, do: %Aspect{with: [PingComponent]}
      def default_action, do: :send_message
      def dispatch(entity, :send_message) do
        component = Entity.find_component(entity, PingComponent)
        send(component.state.pid, component.state.message)
        entity
      end
    end
    pubsub_map = %{PingComponent => [TickSystem]}
    Ecs.Entity.new(
      PingComponent.new(
        %{
          pubsub: pubsub_map,
          delay: 20
        }))

    assert_receive :ping
  end

  @tag skip: "Old test, have to think about it"
  test "figures out if an entity matches an aspect" do
    aspect = Aspect.new(with: [TimeComp], without: [DeathComp])
    dwarf = Entity.new(TimeComp)
    assert Entity.match_aspect?(dwarf, aspect)

    aspect = Aspect.new(with: [TimeComp], without: [DeathComp])
    dwarf = Entity.new([TimeComp, DeathComp])
    assert !(Entity.match_aspect?(dwarf, aspect))
  end

  @tag skip: "Old test, have to think about it"
  test "Entity has a component" do
    dwarf = Entity.new(TimeComp)
    assert Entity.has_component?(dwarf, TimeComp)
  end

  @tag skip: "Old test, have to think about it"
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

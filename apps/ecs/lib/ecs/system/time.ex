defmodule Ecs.System.Time do
  alias Ecs.{Aspect, Component, Entity}
  use Ecs.System

  def aspect, do: %Aspect{with: [Component.Time]}
  def default_action, do: :increment
  def dispatch(entity, :increment) do
    time_comp =
      Entity.find_component(entity, Component.Time)
    new_state = Map.update!(time_comp.state, :age, &(&1 + 1))

    Ecs.GlobalState.save_component(Map.put(time_comp, :state, new_state))
  end
end

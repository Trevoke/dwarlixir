defmodule Ecs.System.Time do
  alias Ecs.{Aspect, Component, Entity}
  use Ecs.System

  def aspect, do: %Aspect{with: [Component.Time]}
  def default_action, do: :increment
  def dispatch(entity, :increment) do
    time_comp =
      Entity.find_component(entity, Component.Time)
    Map.update!(time_comp.state, :age, &(&1 + 1))
  end
end

defmodule Ecs.System.TimeSystem do
  use Ecs.System

  def key, do: Ecs.Component.TimeComponent
  def default_action, do: :increment
  def dispatch(state, :increment) do
    Map.update!(state, :age, &(&1 + 1))
  end
end

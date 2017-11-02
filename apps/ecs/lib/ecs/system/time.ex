defmodule Ecs.System.Time do
  use Ecs.System

  def key, do: Ecs.Component.Time
  def default_action, do: :increment
  def dispatch(state, :increment) do
    Map.update!(state, :age, &(&1 + 1))
  end
end

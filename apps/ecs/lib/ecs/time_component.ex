defmodule Ecs.Component.TimeComponent do
  @component_type __MODULE__
  use Ecs.Component
  def new(initial_state \\ %{age: 1}) do
    Ecs.Component.new(@component_type, initial_state)
  end
end

defmodule Mud.Components.Age do
  @enforce_keys [:age]
  defstruct [:age]

  use Ecs.Component
  def default_value, do: %{age: 1}
end

defmodule Mud.Components.Pregnancy do
  @enforce_keys [:ticks_to_birth]
  defstruct [:ticks_to_birth]

  use Ecs.Component
  def default_value, do: %{ticks_to_birth: 1}
end

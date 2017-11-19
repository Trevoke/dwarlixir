defmodule Mud.Components.AI do
  @enforce_keys [:module]
  defstruct [:module]

  use Ecs.Component
  def default_value, do: %{module: Mud.AI.V1}
end

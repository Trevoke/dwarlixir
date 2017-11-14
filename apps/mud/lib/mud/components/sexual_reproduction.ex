defmodule Mud.Components.SexualReproduction do
  @enforce_keys [:sex]
  defstruct [:sex]

  use Ecs.Component
  def default_value, do: %{sex: Enum.random([:female, :male])}
end

defmodule Mud.Components.Race.Dwarf do
  @enforce_keys [:lifespan]
  defstruct [:lifespan]

  use Ecs.Component
  def default_value do
    %{
        lifespan: 1800 + Enum.random(1..7200)
    }
  end
end

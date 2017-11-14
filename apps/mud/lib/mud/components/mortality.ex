defmodule Mud.Components.Mortality do
  @enforce_keys [:mortal]
  defstruct [:mortal]

  use Ecs.Component
  def default_value, do: %{mortal: true}
end

defmodule Mud.Components.Description do
  @enforce_keys [:long, :short]
  defstruct [:long, :short]

  use Ecs.Component
  def default_value do
    %{
      long: "Nothing to see here.",
      short: "Something."
    }
  end
end

defmodule Mud.Components.Room do
  @enforce_keys [:room_id]
  defstruct [:room_id]

  use Ecs.Component
  def default_value, do: %{room_id: 1}
end

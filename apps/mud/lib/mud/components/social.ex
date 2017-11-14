defmodule Mud.Components.Social do
  @enforce_keys [:name]
  defstruct [:name]

  use Ecs.Component
  def default_value, do: %{name: Faker.Name.name}
end

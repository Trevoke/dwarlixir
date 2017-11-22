defmodule Ecs.Component.Death do
  @enforce_keys [:can_die]
  defstruct [:can_die]
  @type t :: %__MODULE__{
    can_die: boolean
  }

  use Ecs.Component

  def default_value, do: %{can_die: true}
end

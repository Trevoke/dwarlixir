defmodule Ecs.Component.Time do
  @enforce_keys [:age]
  defstruct [:age]
  @type t :: %__MODULE__{
    age: pos_integer()
  }

  use Ecs.Component

  def default_value, do: %{age: 1}
end

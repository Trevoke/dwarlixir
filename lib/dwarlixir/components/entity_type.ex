defmodule Dwarlixir.Components.EntityType do
  @moduledoc """
  Component to track the type/kind of entity (Bird, Dwarf, etc.)
  """
  use Ecstatic.Component

  @default_value %{type: nil, name: "unknown"}
end

defmodule Dwarlixir.Components.Location do
  @moduledoc """
  Component to track which location an entity is in.
  """
  use Ecstatic.Component

  @default_value %{location_id: nil}
end

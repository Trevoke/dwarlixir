defmodule Ecs.Component.TimeComponent do
  use Ecs.Component

  def default_value, do: %{age: 1}
end

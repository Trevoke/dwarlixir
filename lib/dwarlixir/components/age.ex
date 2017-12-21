defmodule Dwarlixir.Components.Age do
  use Ecstatic.Component
  def default_value, do: %{age: 1, life_expectancy: 80}
end

defmodule Dwarlixir.Systems.Aging do
  use Ecstatic.System

  alias Dwarlixir.Components, as: C

  def aspect, do: %Ecstatic.Aspect{with: [C.Age]}

  def dispatch(entity) do
    age = Entity.find_component(entity, C.Age)
    %Ecstatic.Changes{updated: [%{age | state: %{age.state | age: age.state.age + 1}}]}
  end
end

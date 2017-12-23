defmodule Dwarlixir.Systems.OldAge do
  use Ecstatic.System

  alias Dwarlixir.Components, as: C

  def aspect, do: %Ecstatic.Aspect{with: [C.Age, C.Mortal]}

  def dispatch(entity) do
    %Ecstatic.Changes{attached: [C.Dead], removed: [C.Age]}
  end
end

defmodule Dwarlixir.Systems.OldAge do
  use Ecstatic.System

  def aspect: %Ecstatic.Aspect{with: [Age, Mortal]}

  def dispatch(entity) do
    %Ecstatic.Changes{attached: [Dead]}
  end
end

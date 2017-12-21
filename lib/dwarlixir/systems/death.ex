defmodule Dwarlixir.Systems.Death do
  use Ecstatic.System

  def aspect, do: %Ecstatic.Aspect{with: [Mortal]}

  def dispatch(entity) do
    # TODO what happens when something dies, anyway?
  end
end

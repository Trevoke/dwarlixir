defmodule Dwarlixir.Systems.Death do
  use Ecstatic.System

  alias Dwarlixir.Components, as: C

  # Death system handles entities that have been marked as Dead
  def aspect, do: %Ecstatic.Aspect{with: [C.Dead]}

  def dispatch(entity) do
    # When an entity is dead, we destroy it from the ECS
    # TODO: In the future, this should:
    # 1. Create a corpse via Life.Reaper
    # 2. Notify the location of the death
    # 3. Trigger any death-related events
    %Ecstatic.Changes{destroyed: [entity.id]}
  end
end

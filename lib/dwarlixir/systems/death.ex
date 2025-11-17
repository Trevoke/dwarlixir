defmodule Dwarlixir.Systems.Death do
  use Ecstatic.System

  alias Dwarlixir.{Life, World, Components}
  alias Dwarlixir.Components, as: C

  # Death system handles entities that have been marked as Dead
  def aspect, do: %Ecstatic.Aspect{with: [C.Dead]}

  def dispatch(entity) do
    # Extract information from entity components
    location = Entity.find_component(entity, C.Location)
    entity_type = Entity.find_component(entity, C.EntityType)

    # Create corpse if we have the necessary information
    if location && entity_type do
      loc_id = location.state.location_id
      type_module = entity_type.state.type
      entity_name = entity_type.state.name

      # Prepare public info for the corpse
      public_info = %{
        name: "#{entity_name} corpse",
        description: "The remains of a #{entity_name}"
      }

      # Call the Reaper to create a corpse
      Life.Reaper.claim({type_module, entity.id}, loc_id, public_info)

      # Notify the location of the death
      World.Location.announce_death(loc_id, {{type_module, entity.id}, public_info})
    end

    # Destroy the entity from the ECS
    %Ecstatic.Changes{destroyed: [entity.id]}
  end
end

defmodule Mud.Entities.Dwarf do
  alias Ecs.Entity
  alias Mud.Components

  def new do
    Entity.new(components: [
          Components.Race.Dwarf,
          Components.Age,
          Components.Mortality,
          Components.SexualReproduction,
          Components.Social,
          Components.Room,
          Components.Description,
          Components.AI.V1
        ])
  end
end

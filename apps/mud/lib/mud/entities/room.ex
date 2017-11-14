defmodule Mud.Entities.Room do
  alias Ecs.Entity
  alias Mud.Components

  def new do
    Entity.new(components: [
          Components.Container,
          Components.Description
        ])
  end
end

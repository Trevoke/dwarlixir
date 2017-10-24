defmodule Ecs.Entity do
  @moduledoc """
  A base for creating new Entities.
  """

  defstruct [:id, :components]

  @type id :: String.t
  @type components :: list(Ecs.Component)
  @type t :: %Ecs.Entity{
    id: String.t,
    components: components
  }

  @doc "Creates a new entity"
  @spec build(components) :: t
  def build(components) do
    %Ecs.Entity{
      id: UUID.uuid4(:hex),
      components: components
    }
  end

  @doc "Add components at runtime"
  def add(%Ecs.Entity{ id: id, components: components}, component) do
    %Ecs.Entity{
      id: id,
      components: [component | components]
    }
  end

  @doc "Pulls the latest component states"
  @spec reload(t) :: t
  def reload(%Ecs.Entity{ id: _id, components: components} = entity) do
    updated_components =
      components
      |> Enum.map(&Ecs.Component.get(&1.id))

    %{entity | components: updated_components}
  end
end

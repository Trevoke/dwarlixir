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
  @spec new(components) :: t
  def new(components: components) do
    %Ecs.Entity{
      id: UUID.uuid4(:hex),
      components: build(components)
    }
  end

  @spec new(Ecs.Component) :: t
  def new(component), do: new(components: [component])

  @spec new :: t
  def new, do: new(components: [])

  @doc "Add components at runtime"
  def add(%Ecs.Entity{ id: id, components: components}, component) do
    %Ecs.Entity{
      id: id,
      components: [component | components]
    }
  end

  @doc "Check if an entity has an instance of a given component"
  @spec has_component?(t, Ecs.Component) :: boolean
  def has_component?(entity, component) do
    Enum.member?(entity.components, component)
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

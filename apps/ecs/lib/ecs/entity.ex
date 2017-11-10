defmodule Ecs.Entity do
  @moduledoc """
  A base for creating new Entities.
  """

  defstruct [:id, :components]

  @type id :: String.t
  @type uninitialized_component :: struct()
  @type components :: list(Ecs.Component)
  @type t :: %Ecs.Entity{
    id: String.t,
    components: components
  }

  defmodule InvalidComponentError do
    @moduledoc "Thrown if an invalid term is given to the `new` function."
    defexception [:message]
    def exception(not_a_component) do
      msg = "Cannot initialize a new Entity with '#{inspect not_a_component}'"
      %InvalidComponentError{message: msg}
    end
  end

  @doc "Creates a new entity"
  @spec new(components) :: t
  def new(components: components) when is_list(components) do
    build(components)
  end

  def new(components) when is_list(components), do: new(components: components)

  @spec new(uninitialized_component) :: t
  def new(component), do: new(components: [component])

  @spec new :: t
  def new, do: new(components: [])

  def build(components) do
    entity = %Ecs.Entity{id: id()}
    build(entity, components, [])
  end

  def build(entity, [], acc) do
    %{entity | components: acc}
  end

  def build(entity, [%Ecs.Component{} = hd | tl], acc) do
    build(entity, tl, [hd | acc])
  end

  def build(entity, [hd | tl], acc) when is_atom(hd) do
    build(entity, tl, [hd.new | acc])
  end

  def build(_entity, [hd | _tl], _acc) do
    raise InvalidComponentError, hd
  end

  def id, do: UUID.uuid4(:hex)

  @doc "Add a component to an entity"
  @spec add(t, Ecs.Component) :: t
  def add(%Ecs.Entity{components: components} = entity, component) do
    %{entity | components: [ component | components]}
  end

  @doc "Checks if an entity matches an aspect"
  @spec match_aspect?(t, Ecs.Aspect.t) :: boolean
  def match_aspect?(entity, aspect) do
    Enum.all?(aspect.with, &has_component?(entity, &1)) &&
    ! Enum.any?(aspect.without, &has_component?(entity, &1))
  end


  @doc "Check if an entity has an instance of a given component"
  @spec has_component?(t, Ecs.Component.t) :: boolean
  def has_component?(entity, component) do
    entity.components
    |> Enum.map(&(&1.type))
    |> Enum.member?(component)
  end

  @spec find_component(t, Ecs.Component.t) :: Ecs.Component.t | nil
  def find_component(entity, component) do
    Enum.find(entity.components, &(&1.type == component))
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

defmodule Ecs.Entity do
  @moduledoc """
  A base for creating new Entities.
  """

  defstruct [:id, components: []]

  @type id :: String.t
  @type uninitialized_component :: atom()
  @type components :: list(Ecs.Component.t)
  @type t :: %Ecs.Entity{
    id: String.t,
    components: components
  }

  use GenServer

  def init(components) do
    state = build(components)
    {:ok, state}
  end

  def handle_call(:entity, _from, state), do: {:reply, state, state}

  def handle_info({msg, component_type, pubsub}, state) do
    new_state = case Ecs.Entity.has_component?(state, component_type) do
                  false -> state
                  true ->
                    Enum.reduce(
                      pubsub[component_type],
                      state,
                      fn(sys, acc) -> sys.process(acc) end
                    )
                end
    case Ecs.Entity.find_component(new_state, component_type) do
      nil -> nil
      comp -> start_timer_for_component(comp, repeat: true)
    end
    {:noreply, new_state}
  end

  defp start_timer_for_component(
    %Ecs.Component{type: type, state: state},
    repeat: repeat?) do

    if state.schedule == :once && repeat? == true do
      nil
    else
      Process.send_after(
        self(),
        {state.message, type, state.pubsub},
        state.delay
      )
    end
  end


  @doc "Creates a new entity"
  @spec new(components) :: t
  def new(components: components) when is_list(components) do
    {:ok, pid} = GenServer.start(__MODULE__, components)
    GenServer.call(pid, :entity)
  end
  def new(components) when is_list(components), do: new(components: components)

  @spec new(uninitialized_component) :: t
  def new(component), do: new(components: [component])

  @spec new :: t
  def new, do: new(components: [])

  defp build(components) do
    entity = %Ecs.Entity{id: id()}
    Enum.reduce(components, entity, fn
      (%Ecs.Component{} = c, acc) -> Ecs.Entity.add(entity, c)
      (c, acc) when is_atom(c) -> Ecs.Entity.add(entity, c.new)
      (c, acc) -> raise Ecs.InvalidComponentError, c
    end)
  end

  def id, do: UUID.uuid4(:hex)

  @doc "Add an initialized component to an entity"
  @spec add(t, Ecs.Component.t) :: t
  def add(%Ecs.Entity{components: components} = entity, %Ecs.Component{} = component) do
    start_timer_for_component(component, repeat: false)
    %{entity | components: [component | components]}
  end

  @doc "Checks if an entity matches an aspect"
  @spec match_aspect?(t, Ecs.Aspect.t) :: boolean
  def match_aspect?(entity, aspect) do
    Enum.all?(aspect.with, &has_component?(entity, &1)) &&
    ! Enum.any?(aspect.without, &has_component?(entity, &1))
  end


  @doc "Check if an entity has an instance of a given component"
  @spec has_component?(t, uninitialized_component) :: boolean
  def has_component?(entity, component) do
    entity.components
    |> Enum.map(&(&1.type))
    |> Enum.member?(component)
  end

  @spec find_component(t, uninitialized_component) :: Ecs.Component.t | nil
  def find_component(entity, component) do
    Enum.find(entity.components, &(&1.type == component))
  end

end

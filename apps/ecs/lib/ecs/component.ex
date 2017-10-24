defmodule Ecs.Component do
  @moduledoc """
    A base for creating new Components.
  """

  defstruct [:id, :state]

  @type id :: String.t
  @type component_type :: String.t
  @type state :: map()
  @type params :: map()
  @type t :: %Ecs.Component{
    id: id, # Component Agent ID
    state: state
  }

  @callback new(state) :: t

  defmacro __using__(_options) do
    quote do
      @behaviour Ecs.Component
    end
  end

  def via_tuple(id), do: {:via, Registry, {Ecs.ComponentRegistry, id}}

  @doc "Create a new agent to keep the state"
  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    {:ok, state} = Ecs.ComponentAgent.start_link(component_type, initial_state)
    %Ecs.Component{
      id: state.id,
      state: state
    }
  end

  @doc "Retrieves state"
  @spec get(pid) :: t
  def get(pid) when is_pid(pid) do
    Ecs.ComponentAgent.get(pid)
  end

  @doc "Retrieves state"
  @spec get(id) :: t
  def get(id) do
    [{pid, _value}] = Registry.lookup(Ecs.ComponentRegistry, id)
    get(pid)
  end

  @doc "Updates state"
  @spec update(pid, state) :: t
  def update(pid, new_state) when is_pid(pid) do
    Ecs.ComponentAgent.set(pid, new_state)
  end

  @doc "Updates state"
  @spec update(id, state) :: t
  def update(id, new_state) do
    [{pid, _value}] = Registry.lookup(Ecs.ComponentRegistry, id)
    update(pid, new_state)
  end
end

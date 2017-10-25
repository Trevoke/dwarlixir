defmodule Ecs.Component do
  @moduledoc """
  A base for creating new Components.
  """

  defstruct [:id, :state, :type]

  @type params :: map()
  @type id :: String.t
  @type component_type :: String.t
  @type state :: map()
  @type t :: %__MODULE__{
    type: component_type,
    state: state,
    id: id
  }

  @callback default_value :: t

  defmacro __using__(_options) do
    quote do
      @behaviour Ecs.Component
      def new(initial_state \\ %{}) do
        Ecs.Component.new(
          __MODULE__,
          Map.merge(initial_state, default_value())
        )
      end
    end
  end

  @doc "New component"
  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    id = UUID.uuid4(:hex)
    component = struct(
      __MODULE__,
      %{id: id, type: component_type, state: initial_state}
    )
    :ok = Ecs.GlobalState.save_component(component)
    component
  end

  @doc "Retrieves state"
  @spec get(id) :: t
  def get(id) do
    Ecs.GlobalState.get_component_by_id(id)
  end

  @doc "Updates state"
  @spec update(t) :: t
  def update(component) do
    :ok = Ecs.GlobalState.save_component(component)
    component
  end
end

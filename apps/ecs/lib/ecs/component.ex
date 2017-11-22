defmodule Ecs.Component do
  @moduledoc """
  A base for creating new Components.
  """

  defstruct [:id, :state, :type]

  @type params :: map()
  @type id :: String.t
  @type component_type :: atom()
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
          Map.merge(default_value(), initial_state)
        )
      end
    end
  end

  @doc "New component"
  @spec new(component_type, state) :: t
  def new(component_type, initial_state) do
    id = UUID.uuid4(:hex)
    struct(
      __MODULE__,
      %{id: id, type: component_type, state: initial_state}
    )
  end

end

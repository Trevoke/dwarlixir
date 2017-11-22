defmodule Ecs.System do
  alias Ecs.{Aspect, Component, Entity}
  @type state :: map()
  @callback aspect() :: Aspect.t
  @callback default_action() :: atom()
  @callback dispatch(state :: state(), action :: atom()) :: state()

  defmacro __using__(_options) do
    quote do
      @behaviour Ecs.System

      def process(entities) when is_list(entities) do
        entities
        |> processable_by_system
        |> Enum.map(&Task.async(fn() -> dispatch(&1, default_action()) end))
        |> Enum.map(&Task.await(&1))
      end
      def process(entity) do
        if Entity.match_aspect?(entity, aspect()) do
          dispatch(entity, default_action())
        else
          entity
        end
      end

      @spec processable_by_system(entities :: [ Entity.t ]) :: [ Entity.t ]
      defp processable_by_system(entities) do
        Enum.filter(entities, &Entity.match_aspect?(&1, aspect()))
      end
    end
  end

  def dispatch(entity, action), do: raise "What?"

  def aspect, do: %Aspect{}
end

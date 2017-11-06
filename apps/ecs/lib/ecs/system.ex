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
        |> Enum.map(&async_process(&1, default_action()))
        |> Enum.map(&Task.await(&1))
      end
      def process(entity), do: process([entity])

      @spec processable_by_system(entities :: [ Entity.t ]) :: [ Entity.t ]
      defp processable_by_system(entities) do
        Enum.filter(entities, fn(entity) ->
          Enum.all?(aspect().with, &Entity.has_component?(entity, &1)) &&
            !Enum.any?(aspect().without, &Entity.has_component?(entity, &1))
        end)
      end

      defp async_process(entity, action) do
        Task.async(fn -> dispatch(entity, action) end)
      end
    end

  end

  def dispatch(pid, action) when is_pid(pid) do
    state = Component.get(pid)
    dispatch(state, action)
  end

  def aspect, do: %Aspect{}

end

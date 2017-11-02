defmodule Ecs.System do
  @type state :: map()
  @callback key() :: atom()
  @callback default_action() :: atom()
  @callback dispatch(state :: state(), action :: atom()) :: state()

  defmacro __using__(_options) do
    quote do
      @behaviour Ecs.System
      def process do
        key()
        |> Ecs.GlobalState.get_components_by_type
        |> process_entries
      end

      def dispatch(pid, action) when is_pid(pid) do
        state = Ecs.Component.get(pid)
        dispatch(state, action)
      end

      @spec process_entries([Ecs.Component.t]) :: :ok
      defp process_entries(components) do
        #TODO at some point, wonder if batch-saving components here would be nicer.
        #I bet it would be.
        components
        |> Enum.map(&async_process(&1, default_action()))
        |> Enum.map(&Task.await(&1))
      end

      defp async_process(component, action) do
        Task.async(fn ->
          new_state = dispatch(component.state, action)
          Ecs.GlobalState.save_component(%{component | state: new_state})
        end)
      end
    end
  end
end

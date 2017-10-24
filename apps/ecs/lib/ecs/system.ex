defmodule Ecs.System do
  @type state :: map()
  @callback key() :: atom()
  @callback default_action() :: atom()
  @callback dispatch(state :: state(), action :: atom()) :: state()

  defmacro __using__(_options) do
    quote do
      @behaviour Ecs.System
      def process do
        Registry.dispatch(
          Ecs.Registry,
          key(),
          &process_entries/1,
          parallel: true)
      end
      def process(pid, action) do
        Task.start(fn ->
          new_state = dispatch(pid, action)
          Ecs.Component.update(pid, new_state)
        end)
      end
      def dispatch(pid, action) when is_pid(pid) do
        state = Ecs.Component.get(pid)
        dispatch(state, action)
      end
      def dispatch(state, :increment) do
        Map.update!(state, :age, &(&1 + 1))
      end
      defp process_entries(entries) do
        for {pid, _id} <- entries do
          process(pid, default_action())
        end
      end
    end
  end
end

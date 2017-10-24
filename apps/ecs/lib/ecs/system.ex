defmodule Ecs.System do
  def key, do: Ecs.Component.TimeComponent
  def default_action, do: :increment
  def process do
    Registry.dispatch(
      Ecs.Registry,
      key(),
      &process_registry_entries/1,
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
  defp process_registry_entries(entries) do
    for {pid, _id} <- entries do
      process(pid, default_action())
    end
  end
end

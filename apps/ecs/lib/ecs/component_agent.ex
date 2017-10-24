defmodule Ecs.ComponentAgent do
  @moduledoc """
    Create a simple Agent that gets and sets.
    Each component instantiates one to keep state.
  """

  @doc "Starts a new bucket. Returns {:status, pid}"
  def start_link(component_type, initial_state \\ %{}, opts \\ []) do
    id = UUID.uuid4(:hex)
    state = Map.put(initial_state, :id, id)
    init_fn = fn ->
      Registry.register(Ecs.Registry, component_type, id)
      state
    end
    {:ok, _pid} = Agent.start_link(
      init_fn,
      [{:name, Ecs.Component.via_tuple(id)} | opts]
    )
    {:ok, state}
  end

  @doc "Gets entire state from pid"
  def get(pid) do
    Agent.get(pid, &(&1))
  end

  @doc "Gets a value from the `pid` by `key`"
  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  @doc "Overwrites state with new_state."
  def set(pid, new_state) do
    Agent.update(pid, &Map.merge(&1, new_state))
  end

  @doc "Updates the `value` for the given `key` in the `pid`"
  def set(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end
end

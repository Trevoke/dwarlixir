defmodule Controllers.Mob do
  use GenServer

  @tick 1000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    Registry.register(Registry.Tick, :subject_to_time, {__MODULE__, state.id})
    {:ok, state}
  end

  def handle_cast(:tick, state) do
    apply(state.module, :tick, [state.id])
    {:noreply, state}
  end

  def terminate(reason, state) do
    Registry.unregister(Registry.Tick, :subject_to_time)
    reason
  end
end

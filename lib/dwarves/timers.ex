defmodule Dwarves.Timers do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :dwarves_timers)
  end

  def init(:start_heartbeat) do
    {:ok, %{heartbeat: heartbeat_timer()}}
  end

  def init, do: {:ok, %{}}

  def start_heartbeat do
    GenServer.call(:dwarves_timers, {:start_heartbeat})
  end

  def stop_heartbeat do
    GenServer.call(:dwarves_timers, {:stop_heartbeat})
  end

  def handle_call({:start_heartbeat}, _from, state) do
    {:reply, :ok, Map.put(state, :heartbeat, heartbeat_timer())}
  end

  def handle_call({:stop_heartbeat}, _from, %{heartbeat: heartbeat} = state) do
    {:ok, _} = :timer.cancel(heartbeat)
    {:reply, :ok, Map.delete(state, :heartbeat)}
  end

  defp heartbeat_timer do
    {:ok, tref} = :timer.send_interval(1000, :dwarves_registry, {:send_heartbeat})
    tref
  end

end

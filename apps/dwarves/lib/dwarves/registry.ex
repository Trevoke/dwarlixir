defmodule Dwarves.Registry do
  use GenServer

  def start_link(opts) do
    Registry.start_link(:unique, Registry.Mob, partitions: System.schedulers_online)
  end

  def send_heartbeat do
    Registry.dispatch(Registry.Mob, :subject_to_time, fn entries ->
      for {pid, _} <- entries, do: GenServer.cast(pid, {:be})
    end)
  end

  def handle_info({:send_heartbeat}, state) do
    send_heartbeat()
    {:noreply, state}
  end
end

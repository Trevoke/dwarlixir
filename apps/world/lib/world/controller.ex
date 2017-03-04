defmodule HumanController do
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def handle(pid, tuple) do
    GenServer.cast(pid, tuple)
  end

  def handle_cast({:depart, loc_id, mob_id}, state) do
    IO.puts "Mob #{mob_id} is leaving #{loc_id} in direction [not implemented]"
    {:noreply, state}
  end

  def handle_cast({:death, name}, state) do
    IO.puts "#{name} has just died."
    {:noreply, state}
  end

end

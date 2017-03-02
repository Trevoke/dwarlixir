defmodule Controller do
  use GenServer

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def handle(pid, tuple) do
    GenServer.call(pid, tuple)
  end

  def handle_call({:depart, loc_id, mob_id}, _from, state) do
    IO.puts "Mob #{mob_id} is leaving #{loc_id} in direction [not implemented]"
    {:reply, :ok, state}
  end

end

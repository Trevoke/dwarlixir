defmodule Dwarves.World do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link([name: name]) do
    # 1. Pass the name to GenServer's init
    GenServer.start_link(__MODULE__, name, name: name)
  end

  def stop(server) do
    GenServer.stop(server)
  end

  def init(args) do
    {:ok, %{}} # %{ PID => [x, y] }
  end

  ## Server callbacks

  def handle_call({:location_available?, %{x: x, y: y}}, _pid, state) do
    occupied = Map.values(state) |> Enum.member?(%{x: x, y: y})
    {:reply, !occupied, state}
  end

  def handle_cast({:move, pid, new_loc}, state) do
    {:noreply, Map.put(state, pid, new_loc)}
  end

end

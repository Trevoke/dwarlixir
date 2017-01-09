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
    {:ok, %{}} # %{ %{x: x, y: y} => [PID] }
  end

  ## Server callbacks

  def handle_call({:location_available?, location}, _pid, state) do
    occupied = Map.has_key?(state, location)
    {:reply, !occupied, state}
  end

  def handle_cast({:spawn, pid, loc}, state) do
    new_state = Map.put_new(state, loc, [])
    |> update_in([loc], fn(things_at_loc) -> things_at_loc ++ [pid] end)

    {:noreply, new_state}
  end

  def handle_cast({:move, pid, new_loc, loc}, state) do
    new_state = Map.put_new(state, new_loc, [])
    |> update_in([new_loc], fn(things_at_loc) -> things_at_loc ++ [pid] end)
    |> update_in([loc], fn(things_at_loc) -> List.delete(things_at_loc, pid) end)

    {:noreply, new_state}
  end

end

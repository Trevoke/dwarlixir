defmodule Dwarves.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link([name: name]) do
    # 1. Pass the name to GenServer's init
    GenServer.start_link(__MODULE__, name, name: name)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) when is_atom(server) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid} #TODO replace pid with {x, y}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server callbacks

  def init(_args) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    refs = Enum.map((1..50), fn x ->
      {:ok, dwarf_pid} = Dwarf.start_link([initial_values: %{x: x, y: x}])
      :ets.insert(__MODULE__, {"dwarf#{x}", dwarf_pid})
      :timer.send_interval(1000, dwarf_pid, {:be_dwarfy, Dwarves.World})
      dwarf_pid
    end)
    {:ok, {names, refs}}
  end

  # 4. The previous handle_call callback for lookup was removed

  # def handle_cast({:create, name}, {names, refs}) do
  #   # 5. Read and write to the ETS table instead of the map
  #   case lookup(names, name) do
  #     {:ok, _pid} ->
  #       {:noreply, {names, refs}}
  #     :error -> #TODO replace with "add a dwarf to ets"
  #       {:ok, pid} = Dwarves.Bucket.Supervisor.start_bucket
  #       ref = Process.monitor(pid)
  #       refs = Map.put(refs, ref, name)
  #       :ets.insert(names, {name, pid})
  #       {:noreply, {names, refs}}
  #   end
  # end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

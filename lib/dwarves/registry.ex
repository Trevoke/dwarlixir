defmodule Dwarves.Registry do
  use GenServer

  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    GenServer.start_link(__MODULE__, Dwarves.Registry, name: :dwarves_registry)
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

  def whereis_name(dwarf) do
    GenServer.call(:dwarves_registry, {:whereis_name, dwarf})
  end

  def register_name(dwarf, pid) do
    GenServer.call(:dwarves_registry, {:register_name, dwarf, pid})
  end

  def unregister_name(dwarf) do
    GenServer.cast(:registry, {:unregister_name, dwarf})
  end

  def send(dwarf, message) do
    case whereis_name(dwarf) do
      :undefined -> {:badarg, {dwarf, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end


  ## Server callbacks

  def init(_args) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    refs = Enum.map((1..40), fn x ->
      initial_loc = %{x: x, y: x}
      {:ok, dwarf_pid} = Dwarf.start_link([initial_values: initial_loc, name: Faker.Name.name])
      GenServer.cast(Dwarves.World, {:spawn, dwarf_pid, initial_loc})
      :ets.insert(__MODULE__, {"dwarf#{x}", dwarf_pid})
      :timer.send_interval(1000, dwarf_pid, {:be_dwarfy, Dwarves.World})
      dwarf_pid
    end)
    {:ok, %{names: names, refs: refs}}
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
  #
  def handle_call({:whereis_name, dwarf}, _from, state) do
    {:reply, Map.get(state, dwarf, :undefined), state}
  end

  def handle_call({:register_name, dwarf, pid}, _from, state) do
    case Map.get(state, dwarf) do
      nil -> {:reply, :yes, Map.put(state, dwarf, pid)}
      true -> {:reply, :no, state}
    end
  end

  def handle_cast({:unregister_name, dwarf}, state) do
    {:noreply, Map.delete(state, dwarf)}
  end


  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, %{names: names, refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

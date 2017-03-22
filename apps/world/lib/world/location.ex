defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways, corpses: [],
    entities: %{}
  ]
  use GenServer

  alias World.{Location, LocationRegistry, Pathway, PathwayRegistry}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  defp via_tuple(id) do
    {:via, Registry, {LocationRegistry, id}}
  end

  def init(%__MODULE__{pathways: pathways, id: id} = state) do
    launch_known_pathways(id, pathways)
    check_for_other_pathways_to_monitor(id)
    {:ok, state}
  end

  def move(current_location, {module, mob_id}, new_location, public_info) do
    GenServer.cast(via_tuple(current_location), {:move, {module, mob_id}, new_location, public_info})
  end

  def depart(current_location, {module, mob_id}, towards) do
    GenServer.call(via_tuple(current_location), {:depart, {module,mob_id}, towards})
  end

  def arrive(new_location, {{module, id}, public_info}, from) do
    GenServer.call(via_tuple(new_location), {:arrive, {{module, id}, public_info}, from})
  end

  def place(loc_id, mob_id) do
    GenServer.cast(via_tuple(loc_id), {:place, mob_id})
  end

  def mobs(loc_id, filter) do
    GenServer.call(via_tuple(loc_id), {:mobs, filter})
  end

  def mobs(loc_id)do
    mobs(loc_id, fn(_x) -> true end)
  end

  def handle_cast({:place, pid}, state) do
    {:noreply, %Location{state | corpses: [pid | state.corpses]}}
  end

  def handle_cast({:monitor_pathway, pathway_pid}, state) do
    Process.link(pathway_pid)
    {:noreply, state}
  end

  def handle_cast({:move, {module, mob_id}, new_location, mob_public_info}, state) do
    pathway_tuple = {state.id, new_location}
    if Enum.member?(Map.keys(state.entities), {module, mob_id}) do
      Pathway.move(pathway_tuple, {module, mob_id}, mob_public_info)
    else
      IO.puts "#{state.id} does not have #{mob_id}"
    end
    {:noreply, state}
  end

  def handle_call({:depart, {module, mob_id}, to}, _from, state) do
    {:reply, :ok, %Location{state | entities: Map.delete(state.entities, {module, mob_id})}}
  end

  def handle_call({:arrive, {{module, mob_id}, public_info}, from_loc}, _from, state) do
    state.entities
    |> Map.keys
    |> Enum.each(fn({module, id}) ->
      Kernel.apply(module, :handle, [id, {:arrive, public_info, from_loc}]) end)
    {:reply, :ok, %Location{state | entities: Map.put(state.entities, {module, mob_id}, public_info)}}
  end

  def handle_call({:mobs, filter}, _from, state) do
    mobs = Enum.filter(state.entities, filter)
    {:reply, mobs, state}
  end

  defp launch_known_pathways(id, pathways) do
    for %{from_id: from_id, name: name} <- pathways do
      pathway = %Pathway{from_id: from_id, to_id: id, name: name}
      {:ok, pathway_pid} = Pathway.start_link pathway
      GenServer.cast(via_tuple(id), {:monitor_pathway, pathway_pid})
    end
  end

  defp check_for_other_pathways_to_monitor(this_loc_id) do
    Registry.match(PathwayRegistry, {this_loc_id, :_}, :_)
    |> Enum.map(fn({pid, _}) -> pid end)
    |> Enum.each(fn(pid) -> Process.link(pid) end)
  end

end

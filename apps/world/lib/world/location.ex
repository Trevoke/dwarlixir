defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways, corpses: %{},
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

  # TODO an eye will need to do this
  def look(loc_id) do
    GenServer.call(via_tuple(loc_id), :look)
  end

  def move(current_location, {module, mob_id}, new_location, public_info) do
    GenServer.cast(via_tuple(current_location), {:move, {module, mob_id}, new_location, public_info})
  end

  def depart(current_location, {module, mob_id}, towards) do
    GenServer.call(via_tuple(current_location), {:depart, {module, mob_id}, towards})
  end

  def arrive(new_location, {{module, id}, public_info}, from) do
    GenServer.call(via_tuple(new_location), {:arrive, {{module, id}, public_info}, from})
  end

  def place_item(loc_id, corpse_pid, corpse_info) do
    GenServer.cast(via_tuple(loc_id), {:place_item, corpse_pid, corpse_info})
  end

  def mobs(loc_id, filter) do
    GenServer.call(via_tuple(loc_id), {:mobs, filter})
  end

  def mobs(loc_id)do
    mobs(loc_id, fn(_x) -> true end)
  end

  # TODO a hand will need to do this.
  def handle_cast({:place_item, pid, public_info}, state) do
    {:noreply, %Location{state | corpses: Map.put(state.corpses, pid, public_info)}}
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

  def handle_call(:look, _from, state) do
    living_things =
      state.entities
      |> Map.values
      |> Enum.map(&(&1.name))
    items = state.corpses
      |> Map.values
      |> Enum.map(&("the corpse of #{&1.name}"))
    seen_things = %{living_things: living_things, items: items}
    {:reply, seen_things, state}
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

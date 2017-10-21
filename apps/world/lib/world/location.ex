defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways, items: %{},
    entities: %{}
  ]
  @type t :: %World.Location {
    id: String.t,
    name: String.t,
    description: String.t,
    pathways: [World.Pathway.t],
    items: map(),
    entities: map()
  }
  use GenServer

  alias World.{Location, LocationRegistry, Pathway, PathwayRegistry}

  def start_link(%__MODULE__{} = args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  def via_tuple(id) do
    {:via, Registry, {LocationRegistry, id}}
  end

  def init(%__MODULE__{pathways: pathways, id: id} = state) do
    Process.flag(:trap_exit, true)
    {id, nil} = Registry.update_value(LocationRegistry, id, fn(_x) -> id end)
    Registry.register(World.Registry, "location", id)
    pathways =
    for %{from_id: from_id, name: name} <- pathways do
      %Pathway{from_id: from_id, to_id: id, name: name}
  end
    launch_known_pathways(id, pathways)
    check_for_other_pathways_to_monitor(id)
    {:ok, Map.put(state, :pathways, pathways)}
  end

  # TODO will I need to create an eye for this?
  # Or will this need to be just.. In ets?
  def look(loc_id) do
    GenServer.call(via_tuple(loc_id), :look)
  end

  # TODO to_id - always a good idea?
  def depart(current_location, {{module, mob_id}, public_info, to_id}) do
    GenServer.call(via_tuple(current_location), {:depart, {{module, mob_id}, public_info, to_id}})
  end

  def announce_death(current_location, {{module, mob_id}, public_info}) do
    GenServer.cast(via_tuple(current_location), {:announce_death, {{module, mob_id}, public_info}})
  end

  # TODO from can also be from birth, I think?
  def arrive(new_location, {{module, id}, public_info, from}) do
    GenServer.call(via_tuple(new_location), {:arrive, {module, id}, public_info, from})
  end

  def place_item(loc_id, item_ref, item_info) do
    GenServer.call(via_tuple(loc_id), {:place_item, item_ref, item_info})
  end

  def remove_item(loc_id, item) do
    GenServer.cast(via_tuple(loc_id), {:remove_item, item})
  end

  def send_notification(entities, function) do
    entities
    |> Map.keys
    |> Enum.each(function)
  end

  def mobs(loc_id, filter) do
    GenServer.call(via_tuple(loc_id), {:mobs, filter})
  end

  def mobs(loc_id)do
    mobs(loc_id, fn(_x) -> true end)
  end

  def handle_call(:location_data, _from, state) do
    response = %__MODULE__{
      id: state.id,
      name: state.name,
      description: state.description,
      pathways: state.pathways,
      items: %{},
      entities: %{}
    }
    {:reply, response, state}
  end

  # TODO a hand will need to do this.
  def handle_call({:place_item, {module, id}, public_info}, _from, state) do
    Process.link(GenServer.whereis Item.Corpse.via_tuple(id))
    {:reply, :ok, %Location{state | items: Map.put(state.items, {module, id}, public_info)}}
  end

  def handle_call(:look, _from, state) do
    living_things =
      state.entities
      |> Map.values
      |> Enum.map(&(&1.name))
    # TODO get string description from public info?
    # Maybe define it in Item.Corpse.init ?
    items = state.items
      |> Map.values
      |> Enum.map(&(&1.name))
    seen_things = %{
      living_things: living_things,
      items: items,
      description: state.description,
      exits: state.pathways
    }
    {:reply, seen_things, state}
  end

  def handle_call({:depart, {{module, mob_id}, public_info, to_id}}, _from, state) do
    if Enum.member?(Map.keys(state.entities), {module, mob_id}) do
      exit_name =
        Registry.lookup(PathwayRegistry, {to_id, state.id}) ++ [{nil, "seemingly nowhere"}]
        |> List.first
        |> elem(1)

      Process.unlink(GenServer.whereis Kernel.apply(module, :via_tuple, [mob_id]))

      send_notification(
        state.entities,
        fn({module, id}) ->
          Kernel.apply(module, :handle, [id, {:depart, public_info, exit_name}])
        end)
      {:reply, :ok, %Location{state | entities: Map.delete(state.entities, {module, mob_id})}}
    else
      IO.inspect "{#{module}, #{mob_id}} is not in loc #{state.id} yet wants to go to #{to_id}."
      {:reply, :not_in_location, state}
    end
  end

  def handle_call({:arrive, {module, mob_id}, public_info, from_loc}, _from, state) do
    incoming_exit_name =
      Enum.find(state.pathways, %{}, fn(pathway) ->
        pathway.from_id == from_loc
      end)
      |> Map.get(:name, "seemingly nowhere")

    Process.link(GenServer.whereis Kernel.apply(module, :via_tuple, [mob_id]))

    send_notification(
      state.entities,
      fn({module, id}) ->
        Kernel.apply(module, :handle, [id, {:arrive, public_info, incoming_exit_name}])
      end)
    {
      :reply,
      {:ok, state.pathways},
      %Location{state | entities: Map.put(state.entities, {module, mob_id}, public_info)}
    }
  end

  def handle_call({:mobs, filter}, _from, state) do
    mobs = Enum.filter(state.entities, filter)
    {:reply, mobs, state}
  end

  # TODO make it a call
  def handle_cast({:remove_item, {module, id}}, state) do
    Process.unlink(GenServer.whereis Item.Corpse.via_tuple(id))
    {:noreply, %__MODULE__{state | items: Map.delete(state.items, {module, id})}}
  end

  def handle_cast({:announce_death, {{module, mob_id}, public_info}}, state) do
    leftover_entities = Map.delete(state.entities, {module, mob_id})
    send_notification(
      leftover_entities,
      fn({module, id}) ->
        Kernel.apply(module, :handle, [id, {:death, public_info}])
      end)

    {:noreply, %Location{state | entities: leftover_entities}}
  end

  def handle_cast({:monitor_pathway, pathway_pid}, state) do
    Process.link(pathway_pid)
    {:noreply, state}
  end

  defp launch_known_pathways(id, pathways) do
    Enum.each(pathways, fn(pathway) ->
      {:ok, pid} = Pathway.start_link pathway
      GenServer.cast(via_tuple(id), {:monitor_pathway, pid})
    end)
  end

  defp check_for_other_pathways_to_monitor(this_loc_id) do
    World.Registry
    |> Registry.match("pathway", {this_loc_id, :_})
    |> Enum.map(fn({pid, _}) -> pid end)
    |> Enum.each(fn(pid) -> Process.link(pid) end)
  end

  def terminate(reason, state) do
    Registry.unregister(LocationRegistry, state.id)
    reason
  end

end

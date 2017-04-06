defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways, corpses: %{},
    entities: %{}
  ]
  use GenServer

  alias World.{Location, LocationRegistry, Pathway, PathwayRegistry}

  def start_link(%__MODULE__{} = args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  defp via_tuple(id) do
    {:via, Registry, {LocationRegistry, id}}
  end

  def init(%__MODULE__{pathways: pathways, id: id} = state) do
    {id, nil} = Registry.update_value(LocationRegistry, id, fn(_x) -> id end)
    launch_known_pathways(id, pathways)
    check_for_other_pathways_to_monitor(id)
    {:ok, state}
  end

  # TODO will I need to create an eye for this?
  def look(loc_id) do
    GenServer.call(via_tuple(loc_id), :look)
  end

  def depart(current_location, {{module, mob_id}, public_info, to_id}) do
    GenServer.call(via_tuple(current_location), {:depart, {{module, mob_id}, public_info, to_id}})
  end

  def arrive(new_location, {{module, id}, public_info, from}) do
    GenServer.call(via_tuple(new_location), {:arrive, {module, id}, public_info, from})
  end

  def place_item(loc_id, corpse_pid, corpse_info) do
    GenServer.cast(via_tuple(loc_id), {:place_item, corpse_pid, corpse_info})
  end

  def remove_item(loc_id, item) do
    GenServer.cast(via_tuple(loc_id), {:remove_item, item})
  end

  def handle_cast({:remove_item, item}, state) do
    {:noreply, %__MODULE__{state | corpses: Map.delete(state.corpses, item)}}
  end

  def send_notification(state, function) do
    state.entities
    |> Map.keys
    |> Enum.each(function)
  end

  def mobs(loc_id, filter) do
    GenServer.call(via_tuple(loc_id), {:mobs, filter})
  end

  def mobs(loc_id)do
    mobs(loc_id, fn(_x) -> true end)
  end

  # TODO a hand will need to do this.
  def handle_cast({:place_item, item, public_info}, state) do
    {:noreply, %Location{state | corpses: Map.put(state.corpses, item, public_info)}}
  end

  def handle_cast({:monitor_pathway, pathway_pid}, state) do
    Process.link(pathway_pid)
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

      send_notification(
        state,
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

    send_notification(state, fn({module, id}) ->
      Kernel.apply(
        module,
        :handle,
        [id, {:arrive, public_info, incoming_exit_name}])
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

  # def stop(loc_id), do: GenServer.stop(via_tuple(loc_id))

  # def terminate(reason, state) do
  #   for %{from_id: from_id, name: name} <- state.pathways do
  #     World.Pathway.stop(from_id, state.id)
  #   end
  # end

end

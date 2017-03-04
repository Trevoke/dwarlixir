defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways, mobs: []
  ]
  use GenServer

  alias World.{LocationRegistry, Pathway, PathwayRegistry}

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

  def track(location_id, mob_id) do
    GenServer.cast(via_tuple(location_id), {:track, mob_id})
  end

  def move(current_location, mob_id, new_location) do
    GenServer.cast(via_tuple(current_location), {:move, mob_id, new_location})
  end

  def depart(current_location, mob_id) do
    GenServer.call(via_tuple(current_location), {:depart, mob_id})
  end

  def arrive(new_location, mob_id) do
    GenServer.call(via_tuple(new_location), {:arrive, mob_id})
  end

  def handle_cast({:monitor_pathway, pathway_pid}, state) do
    Process.link(pathway_pid)
    {:noreply, state}
  end

  def handle_cast({:track, mob_id}, state) do
    new_state = %{state | mobs: state.mobs ++ [mob_id]}
    {:noreply, new_state}
  end

  def handle_cast({:move, mob_id, new_location}, state) do
    pathway_tuple = {state.id, new_location}
    if Enum.member?(state.mobs, mob_id) do
      Pathway.move(pathway_tuple, mob_id)
    else
      IO.puts "#{state.id} does not have #{mob_id}"
    end
    {:noreply, state}
  end

  def handle_call({:depart, mob_id}, _from, state) do
    {:reply, :ok, %{state | mobs: state.mobs -- [mob_id]}}
  end

  def handle_call({:arrive, mob_id}, _from, state) do
    {:reply, :ok, %{state | mobs: state.mobs ++ [mob_id] }}
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

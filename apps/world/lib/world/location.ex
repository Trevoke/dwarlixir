defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways
  ]
  use GenServer

  alias World.Pathway

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: via_tuple(args.id))
  end

  defp via_tuple(id) do
    {:via, Registry, {World.LocationRegistry, id}}
  end

  def init(%__MODULE__{
        pathways: pathways,
        id: id
           } = state) do
    launch_known_pathways(id, pathways)
    check_for_other_pathways_to_monitor(id)
    {:ok, state}
  end

  defp launch_known_pathways(id, pathways) do
    for pathway <- pathways do
      pathway = %Pathway{pathway | to_id: id}
      {:ok, pathway_pid} = Pathway.start_link %Pathway{pathway | to_id: id}
      GenServer.cast(via_tuple(id), {:monitor_pathway, pathway_pid})
    end
  end

  defp check_for_other_pathways_to_monitor(this_loc_id) do
    Registry.match(World.PathwayRegistry, {this_loc_id, :_}, :_)
    |> Enum.map(fn({pid, _}) -> pid end)
    |> Enum.each(fn(pid) -> Process.link(pid) end)
  end

  def handle_cast({:monitor_pathway, pathway_pid}, state) do
    Process.link(pathway_pid)
    {:noreply, state}
  end

end

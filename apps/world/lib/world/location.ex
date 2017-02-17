defmodule World.Location do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%{
        incoming_pathways: pathways,
        room_id: id
           } = state) do
    for pathway_id <- pathways do
      World.Pathway.start_link(%{from: pathway_id, to: id})
    end

    IO.puts id
    IO.inspect self
    {:ok, _} = Registry.register(World.LocationRegistry, :location, id)

    {:ok, state}
  end

end

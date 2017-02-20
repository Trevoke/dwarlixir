defmodule World.Location do
  defstruct [
    :id, :name, :description, :pathways
  ]
  use GenServer

  alias World.Pathway

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(%__MODULE__{
        pathways: pathways,
        id: id
           } = state) do
    for pathway <- pathways do
      %Pathway{pathway | to_id: id}
      |> Pathway.start_link
      #Pathway.start_link(%{from_id: pathway_id, to_id: id})
    end

    {:ok, _} = Registry.register(World.LocationRegistry, id, id)

    {:ok, state}
  end

end

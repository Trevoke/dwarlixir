defmodule World.Location do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

end

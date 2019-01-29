defmodule Dwarlixir.Connections.Tcp do
  alias Dwarlixir.Connections, as: DConn

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(port) do
    opts = [port: port]
    {:ok, _} =
      :ranch.start_listener(
        DConnTCP,
        100,
        :ranch_tcp,
        opts,
        DConn.RanchHandler,
        []
      )
  end
end

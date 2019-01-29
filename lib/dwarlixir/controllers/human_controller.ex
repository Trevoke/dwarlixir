defmodule Dwarlixir.Controllers.Human do
  alias __MODULE__.{Impl, Server}

  defstruct [
    :transport,
    :socket,
    :id,
    :entity,
    :location_id,
    exits: [],
    messages: []
  ]

  def log_in(user_id, password, transport, socket) do
    Impl.log_in(user_id, password, transport, socket)
  end

  def handle(user_id, message) do
    Server.handle(user_id, message)
  end

end

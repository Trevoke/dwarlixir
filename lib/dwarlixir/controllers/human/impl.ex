defmodule Dwarlixir.Controllers.Human.Impl do
  alias Dwarlixir.Controllers.Human
  alias Human.Server

  def log_in(user_id, _password, transport, socket) do
    user_id = String.trim user_id
    params =
      %Human{
        id: user_id,
        socket: socket,
        transport: transport,
        entity: Dwarlixir.Entities.PlayerCharacter.new
      }
    case Server.start_link(params) do
      {:ok, _pid} -> {:ok, user_id}
      {:error, {:already_started, _pid}} -> {:error, :username_taken}
    end

    #room = 1
    #Human.join_room(user_id, room)
  end
end

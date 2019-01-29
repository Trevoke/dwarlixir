defmodule Dwarlixir.Connections.RanchHandler do

  alias Dwarlixir.{World, Controllers.Human}

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    loop(socket, transport)
  end

  def loop(socket, transport) do
    write_line(transport, socket, "Choose a username: ")
    {:ok, username} = read_line(transport, socket)
    case Human.log_in(username, "password", transport, socket) do
      {:ok, user_id} ->
        Human.handle(user_id, {:input, "help"})
        loop_connection(transport, socket, user_id)
      {:error, :username_taken} ->
        write_line(transport, socket, "Username already online. Try another.\n")
        loop(socket, transport)
      {:error, error} -> write_line(transport, socket, error)
      _ ->
        :ok = transport.close(socket)
    end
    # TODO disconnect on bad login
    # TODO graceful exit
    # TODO graceful error handling?
  end

  def loop_connection(transport, socket, user_id) do
    case read_line(transport, socket) do
      {:ok, input} ->
        Human.handle(user_id, {:input, input})
        loop_connection(transport, socket, user_id)
      {:error, :closed} -> nil
    end
  end

  def read_line(transport, socket) do
    transport.recv(socket, 0, 5000)
    #:gen_tcp.recv(socket, 0)
  end

  def write_line(transport, socket, line) do
    transport.send(socket, line)
    #:gen_tcp.send(socket, line)
  end
end

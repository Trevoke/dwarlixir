defmodule Connections.Tcp do

  require Logger

  @doc """
  Starts accepting connections on the given `port`.
  """
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      Connections.TaskSupervisor,
      fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    # TODO eventually actually log in, yeah?
    case HumanController.log_in("user1", "password", socket) do
      {:ok, user_id} ->
        HumanController.join_room(user_id, "1")
        loop_connection(socket, user_id)
      {:error, error} -> write_line(socket, error)
    end
    # TODO disconnect on bad login
    # TODO graceful exit
    # TODO graceful error handling?
  end

  def loop_connection(socket, user_id) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, input} ->
        HumanController.handle(user_id, {:input, input})
        loop_connection(socket, user_id)
      {:error, :closed} -> IO.puts "Connection closed"
    end
  end

    defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end

end

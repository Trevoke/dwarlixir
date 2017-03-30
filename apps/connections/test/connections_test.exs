defmodule ConnectionsTest do
  use ExUnit.Case
  doctest Connections

  test "A user can log in and quit" do
    {:ok, _} = World.Location.start_link(
      %World.Location{
        id: "1",
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 4040, [
          :binary, packet: :raw, active: :false
        ])
    :gen_tcp.send(socket, "look\n")
    {:ok, x} = :gen_tcp.recv(socket, 0)
    room_desc = x |> String.split("\n") |> List.first
    assert room_desc == "what's on the tin"
    :gen_tcp.send(socket, "quit\n")
    {:ok, x} = :gen_tcp.recv(socket, 0)
    assert String.trim(x) == "Goodbye."
  end

end

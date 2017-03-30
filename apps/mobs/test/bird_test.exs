defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "only mates with birds" do
    import IEx
    {:ok, foo} = World.Location.start_link(
      %World.Location{
        id: "2",
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    female_bird = Mobs.Spawn.birth(
      %{module: Mobs.Bird, location_id: "2", gender: :female})
    male_dwarf = Mobs.Spawn.birth(
      %{module: Mobs.Dwarf, location_id: "2", gender: :male})
    IO.puts "genserver.whereis..."
    IO.inspect GenServer.whereis({:via, Registry, {World.LocationRegistry, "2"}})
        IO.puts "locationregistry match all..."
    IO.inspect Registry.match(World.LocationRegistry, :_, :_)
    :ok = Mobs.Bird.try_to_mate(female_bird)
    # check that it failed to mate
    # kill dwarf
    # spawn male bird
    # ask female bird to mate
    # check that it did.
    #GenServer.stop(female_bird)
    #GenServer.stop(male_dwarf)
   # World.Location.stop("1")
  end

  @tag skip: true
  test "does not mate with self" do
    assert false == true
  end
end

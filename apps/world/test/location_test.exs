defmodule World.LocationTest do
  use ExUnit.Case
  doctest World.Location

  # TODO add test for pathways dying and respawning with loc

  test "when a location dies it kills everything inside it and respawns" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _locpid} = World.start_child(
      %World.Location{
        id: loc_id,
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    {:ok, male_dwarf} = Mobs.birth(
      %{gender: :male, module: Mobs.Dwarf, location_id: loc_id, lifespan: 1000})
    # TODO on second thought maybe the item supervisor shouldn't place
    # the item in the room?
    Item.Supervisor.create(:corpse, loc_id, %{id: "id", name: "Foo"})

    Process.exit(GenServer.whereis(World.Location.via_tuple(loc_id)), :kill)

    # TODO oh good, sleeping
    Process.sleep 20
    contents = World.Location.look(loc_id)
    assert length(contents.items) == 0
    assert length(contents.living_things) == 0
  end

end

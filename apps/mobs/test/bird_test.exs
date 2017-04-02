defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "is replaced by a corpse (TODO 'all things that die')" do
    loc_id = UUID.uuid4(:hex)
    {:ok, _locpid} = World.Location.start_link(
      %World.Location{
        id: loc_id,
        name: "center of the universe",
        description: "what's on the tin",
        pathways: []}
    )
    female_bird = Mobs.Spawn.birth(
      %{module: Mobs.Bird, location_id: loc_id, lifespan: 1})
    Mobs.Bird.tick(female_bird)
    # TODO oh good, sleeping
    Process.sleep 20
    contents = World.Location.look(loc_id)
    assert length(contents.items) == 1
  end

end

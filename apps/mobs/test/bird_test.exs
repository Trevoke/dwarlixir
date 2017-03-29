defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "only mates with birds" do
    female_bird = Mobs.Spawn.birth(%{module: Mobs.Bird, location_id: "1", gender: :female})
    male_dwarf = Mobs.Spawn.birth(%{module: Mobs.Dwarf, location_id: "1", gender: :male})
    :ok = Mobs.Bird.try_to_mate(female_bird)
    # check that it failed to mate
    # kill dwarf
    # spawn male bird
    # ask female bird to mate
    # check that it did.
  end

  @tag skip: true
  test "does not mate with self" do
    assert false == true
  end
end

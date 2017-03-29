defmodule Mobs.BirdTest do
  use ExUnit.Case
  doctest Mobs.Bird

  test "only mates with birds" do
    IO.inspect World.Location.mobs("1")
    # spawn a male bird
    # spawn a female dwarf
    # ask bird to mate
    # check that it failed to mate
    # kill dwarf
    # spawn female bird
    # ask male bird to mate
    # check that it did.
  end

  @tag skip: true
  test "does not mate with self" do
    assert false == true
  end
end

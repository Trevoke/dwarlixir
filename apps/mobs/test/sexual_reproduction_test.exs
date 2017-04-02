defmodule Mobs.SexualReproductionTest do
  use ExUnit.Case
  doctest Mobs.SexualReproduction

  test "female reproduces with male, same species" do
    male_bird = %{{Mobs.Bird, 2} => %{id: 2, gender: :male}}
    state = %{id: 1, gender: :female}
    {:ok, {_new_state, messages}} = Mobs.SexualReproduction.call(
      {state, []},
      {
        :female,
        :male,
        Mobs.Bird,
        male_bird
      })
    assert length(messages) == 1
    assert List.first(messages) == {Mobs.Bird, :pregnantize, [1]}
  end

  test "male reproduces with female, same species" do
    female_bird = %{{Mobs.Bird, 2} => %{id: 2, gender: :female}}
    state = %{id: 1, gender: :male}
    {:ok, {_new_state, messages}} = Mobs.SexualReproduction.call(
      {state, []},
      {
        :male,
        :female,
        Mobs.Bird,
        female_bird
      })
    assert length(messages) == 1
    assert List.first(messages) == {Mobs.Bird, :pregnantize, [2]}
  end

  test "no reproduction with different species" do
    female_dwarf = %{{Mobs.Dwarf, 2} => %{id: 2, gender: :female}}
    state = %{id: 1, gender: :male}
    {:ok, {_new_state, messages}} = Mobs.SexualReproduction.call(
      {state, []},
      {
        :male,
        :female,
        Mobs.Bird,
        female_dwarf
      })
    assert Enum.empty?(messages)
  end


end

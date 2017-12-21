defmodule Dwarlixir.Watchers do
  use Ecstatic.Watcher

  alias Dwarlixir.Components, as: C
  alias Dwarlixir.Systems, as: S

  watch_component C.Age, :bound, fn -> true end, S.StartAgingTick
  watch_component C.Age, :unbound, fn -> true end, S.StopAgingTick
  watch_component C.Age, :updated, fn(_pre, post) -> post.age > post.life_expectancy end, S.OldAgeSystem
end

defmodule Dwarlixir.Watchers do
  use Ecstatic.Watcher

  alias Dwarlixir.Components, as: C
  alias Dwarlixir.Systems, as: S

  watch_component C.Age, :attached, fn(_e, _c) -> true end, S.StartAgingTick
  watch_component C.Age, :removed, fn(_e, _c) -> true end, S.StopAgingTick
  watch_component C.Age, :updated, fn(_e, post) -> post.state.age > post.state.life_expectancy end, S.OldAgeSystem
end

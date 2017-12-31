defmodule Dwarlixir.Watchers do
  use Ecstatic.Watcher

  alias Dwarlixir.Components, as: C
  alias Dwarlixir.Systems, as: S

  watch_component C.Age, run: S.Aging, every: 6_000
  watch_component C.Age,
    run: S.Dying,
    when: fn(_e, c) -> c.state.age > c.state.life_expectancy end

  watch_component C.Age, :updated,
  fn(_e, post) -> post.state.age > post.state.life_expectancy end, S.OldAgeSystem
end

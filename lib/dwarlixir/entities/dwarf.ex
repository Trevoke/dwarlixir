defmodule Dwarlixir.Entities.Dwarf do
  use Ecstatic.Entity

  alias Dwarlixir.Components, as: C

  @default_components [C.Age, C.Mortal]

  #defp random_lifespan(:short), do: 300 + Enum.random(1..200)
  #defp random_lifespan(_args), do: 1800 + Enum.random(1..7200)
end

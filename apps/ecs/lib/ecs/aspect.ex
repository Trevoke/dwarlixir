defmodule Ecs.Aspect do
  defstruct [
    with: [],
    without: []
  ]

  @type t :: %Ecs.Aspect{
    with: [ atom() ],
    without: [ atom() ]
  }
end

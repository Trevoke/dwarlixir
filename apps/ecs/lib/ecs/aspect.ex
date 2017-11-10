defmodule Ecs.Aspect do
  defstruct [
    with: [],
    without: []
  ]

  @type t :: %Ecs.Aspect{
    with: [ atom() ],
    without: [ atom() ]
  }

  def new(with: with_components, without: without_components)
  when is_list(without_components)
  when is_list(with_components) do
    %Ecs.Aspect{
      with: with_components,
      without: without_components
    }
  end
end

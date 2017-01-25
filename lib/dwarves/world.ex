defmodule Dwarves.World do

  def start_link(_opts) do
    Registry.start_link(:unique, __MODULE__, partitions: System.schedulers_online)
  end

  def location_available?(loc) do
    Enum.empty? Registry.match(__MODULE__, self(), loc)
  end

  def add(loc) do
    Registry.register(__MODULE__, self(), loc)
  end

  def move(new_loc) do
    {new_loc, _} = Registry.update_value(__MODULE__, self(), fn(x) -> new_loc end)
  end

  def current_location() do
    [{_, loc}] = Registry.lookup(__MODULE__, self())
    loc
  end

end

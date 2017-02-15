defmodule Dwarves.World do
  use GenServer
  import Ex2ms

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    :ets.new(__MODULE__, [:bag, :named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

  def terminate(_reason, _state) do
    :ets.delete(__MODULE__)
  end


  def location_available?(loc) do
    Enum.empty? :ets.lookup(__MODULE__, loc)
  end

  def add(loc) do
    :ets.insert(__MODULE__, {loc, self()})
  end

  def move(old_loc, new_loc) do
    :ets.match_delete(__MODULE__, {old_loc, self()})
    :ets.insert(__MODULE__, {new_loc, self()})
  end

  def neighbors({x, y}) do
    filter = fun do {{neighbor_x, neighbor_y}, dwarf}
      when neighbor_x >= ^x - 1
      and neighbor_x != ^x
      and neighbor_x <= ^x + 1
      and neighbor_y >= ^y - 1
      and neighbor_y != ^y
      and neighbor_y <= ^y + 1
                   -> dwarf
    end

    :ets.select(__MODULE__, filter)
  end

end

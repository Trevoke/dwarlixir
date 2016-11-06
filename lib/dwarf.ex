defmodule Dwarf do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([initial_values: %{x: x, y: y}]) do
    {:ok, %{x: x, y: y}}
  end

  def init(args) do
    IO.inspect args
    end
end


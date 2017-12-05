defmodule Dwarlixir.Ecosystem do
  alias Dwarlixir.Mobs
  @moduledoc """
  Documentation for Ecosystem.
  """

  use GenServer

  def start_link(%{} = args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(%{} = state) do
    {:ok, tref} = Petick.start(
      interval: 300000, callback: {__MODULE__, :check_system}
    )
    state = Map.put(state, :tref, tref)
    {:ok, state}
  end

  def free_percentage_of_memory(mem_data_list) do
    total = mem_data_list[:total_memory]
    free = mem_data_list[:free_memory]
    free / total * 100
  end

  def check_system(_pid) do
    GenServer.cast(__MODULE__, :check_system)
  end

  def handle_cast(:check_system, state) do
    mem_data_list = :memsup.get_system_memory_data
    ecosystem_sanity(free_percentage_of_memory(mem_data_list))
    {:noreply, state}
  end

  def ecosystem_sanity(percentage) when percentage < 10 do
    Mobs.deny_births
  end

  # TODO if the percentage is never more than 30, oops.
  def ecosystem_sanity(percentage) when percentage > 30 do
    Mobs.allow_births
  end

  def ecosystem_sanity(_percentage), do: nil

end

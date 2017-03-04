defmodule GenericMobController do
  use GenServer

  @tick 1000

  def start_link(args \\ %{}) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(state) do
    {:ok, timer_ref} = :timer.send_interval(@tick, :tick)
      #Petick.start(interval: @tick, callback: {GenericMobController, :tick})
    #Registry.register(Registry.Tick, state.id, timer_pid)
    {:ok, %{state | timer_ref: timer_ref}}
  end

  # def tick(controller_pid) do
  #   IO.puts "yes? #{inspect self()} #{inspect controller_pid}"

  #   GenServer.cast(controller_pid, :tick)
  # end

  def handle_info(:tick, state) do
    Dwarf.tick(state.id)
    {:noreply, state}
  end
end

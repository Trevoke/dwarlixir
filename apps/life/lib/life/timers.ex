defmodule Life.Timers do
  use GenServer

  def start_link(%{} = opts) do
    GenServer.start_link(__MODULE__, opts, name: :life_timers)
  end

  def init(%{start_heartbeat: true}), do: {:ok, %{heartbeat: new_timer()}}
  def init(args), do: {:ok, args}

  def start_heartbeat do
    GenServer.call(:life_timers, :start_heartbeat)
  end

  def stop_heartbeat do
    GenServer.call(:life_timers, :stop_heartbeat)
  end

  def handle_call(:start_heartbeat, _from, state) do
    tref = new_timer()
    {:reply, tref, Map.put(state, :heartbeat, tref)}
  end

  def handle_call(:stop_heartbeat, _from, %{heartbeat: heartbeat} = state) do
    :ok = Petick.terminate(heartbeat)
    {:reply, :ok, Map.delete(state, :heartbeat)}
  end

  def handle_call(:stop_heartbeat, _from, state), do: {:reply, :no_heartbeat, state}

  defp new_timer do
    {:ok, tref} =
      Petick.start(
      interval: 1000,
      callback: {__MODULE__, :send_heartbeat})
    tref
  end

  def send_heartbeat(_calling_pid) do
    Registry.dispatch(Registry.Tick, :subject_to_time, fn entries ->
      for {proc_ref, _} <- entries, do: GenServer.cast(proc_ref, :tick)
    end)
  end


end

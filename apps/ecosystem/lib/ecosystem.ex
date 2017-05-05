defmodule Ecosystem do
  @moduledoc """
  Documentation for Ecosystem.
  """

  use GenEvent

  def start_link(%{} = args) do
    GenEvent.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(%{} = state) do
    GenEvent.swap_handler(:alarm_handler, :alarm_handler, :swap, __MODULE__, [])
    #
    {:ok, state}
  end

  def handle_event({:system_memory_high_watermark, []}, state) do
    # TODO Tell mobs app to stop allowing births.. And pregnancies?
    {:ok, state}
  end

  def handle_event({:system_memory_high_watermark, _pid}, state) do
    {:ok, state}
  end

end

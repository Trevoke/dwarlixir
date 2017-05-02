defmodule Ecosystem do
  @moduledoc """
  Documentation for Ecosystem.
  """

  use GenServer

  def start_link(%{} = args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end


end

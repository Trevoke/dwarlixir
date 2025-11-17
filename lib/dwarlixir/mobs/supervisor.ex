defmodule Dwarlixir.Mobs.Supervisor do
  @moduledoc """
  Supervisor for mob-related processes.

  In the ECS architecture, individual mobs are not separate processes.
  This supervisor exists primarily for any mob-related GenServers or
  auxiliary processes needed for mob management.
  """

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # ECS entities don't need individual supervision
    # This supervisor can be extended if needed for mob-related processes
    children = []

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Mobs do
  use Application

  def start(_type, _args) do
    Mobs.Supervisor.start_link()
  end

end

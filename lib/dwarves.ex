defmodule Dwarves do
  use Application

  def start(_type, _args) do
    Dwarves.Supervisor.start_link()
  end

end

use Mix.Config

config :elixir, ansi_enabled: true
config :connections, :tcp, port: 4040

import_config "#{Mix.env}.exs"

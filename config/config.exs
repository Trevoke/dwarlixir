# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger,
   handle_otp_reports: true,
   handle_sasl_reports: true

config :logger, level: :warn

config :logger,
  backends: [{LoggerFileBackend, :error_log}]

config :logger, :error_log,
  path: "#{Path.expand(".")}/var/log/error.log"

config :sasl,
  sasl_error_logger: {:file, 'var/log/sasl_errors.log'},
  error_logger_mf_dir: 'var/log/',
  error_logger_mf_maxbytes: 1000,
  error_logger_mf_maxfiles: 10


# Two options: :short and :long
#config :mobs, lifespan: :short

# Whether to have mobs auto-spawned when this app starts up
#config :mobs, spawn_on_start: true

#config :life, start_heartbeat: true

config :elixir, ansi_enabled: true

import_config "#{Mix.env}.exs"

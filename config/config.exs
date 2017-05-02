# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

 config :logger,
   handle_otp_reports: true,
   handle_sasl_reports: true

config :logger, level: :warn

config :logger,
  backends: [{LoggerFileBackend, :error_log}]

config :logger, :error_log,
  path: "var/log/error.log"

config :sasl,
  sasl_error_logger: {:file, 'var/log/sasl_errors.log'},
  error_logger_mf_dir: 'var/log/',
  error_logger_mf_maxbytes: 1000,
  error_logger_mf_maxfiles: 10

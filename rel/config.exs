# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :">FZUQ]xH_HGpGaWrUCL51*z_|w}PT5t_<q3fofRibhEGyi})/=RXDE@)0|8%cxTU"
end

environment :prod do
  set include_erts: "/Users/aldric/src/vendor/rmud-erl-lib/erlang/"
  set include_src: false
  set cookie: :"^Q}&Sik<I~|X=]w,3{.=<mK`mkwKC~llBS%q~`q{PpNyIb_(tm30@4Q4v1_S!iPA"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :dwarlixir do
  set version: "0.4.2"
  set run_erl_env: "RUN_ERL_LOG_MAXSIZE=10000000 RUN_ERL_LOG_GENERATIONS=100"
  set applications: [
    :runtime_tools,
    connections: :permanent,
    controllers: :permanent,
    item: :permanent,
    life: :permanent,
    mobs: :permanent,
    utils: :permanent,
    world: :permanent
  ]
end

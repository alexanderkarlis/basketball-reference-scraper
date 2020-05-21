use Mix.Config

config :scores,
  teams: "https://www.basketball-reference.com/teams/",
  download_path: System.get_env("BBALL_DATA_PATH") || "./data/"

config :logger, :console,
  format: "[$date $time] $message\n",
  colors: [enabled: true]

defmodule Scores.CLI.Teams do
  @moduledoc """
  Usage:
    scores --team <team> --year <year>

  Arguments --
    teams // returns a keyword list of full team name and a team code to be used
    download // pass in a team code and year to download year or years of team stats.
  """
  @download_base_dir Application.fetch_env!(:scores, :download_path)

  require Logger
  alias Logger, as: L
  alias Scores.Teams

  def main(args) do
    args
    |> parse_args
    |> process
  end

  defp parse_args(argv) do
    options = [
      switches: [help: :boolean, teams: :string, year: :string],
      aliases: [h: :help, t: :team, y: :year]
    ]
    parse = OptionParser.parse(
      argv,
      options
    )
    case parse do
      {[help: true], _, _} -> :help
      {options, args, _} -> {options, args}
    end
  end

  defp process(:help) do
    IO.puts @moduledoc
    System.halt(0)
  end

  defp process({opts, args}) do
    IO.inspect args
    IO.inspect opts
    IO.inspect(Enum.at(args, 0))

    case Enum.at(args, 0) do
      "teams"    -> show_team_names_map()
      "download" -> download_tables_to_csv(parse_teams(opts), parse_year(opts))
      _          -> L.log :error, "#{args} not a valid command"
    end
  end

  defp parse_teams(opts) do
    IO.inspect(opts[:teams])
    IO.inspect(String.split(opts[:teams]))
    String.split(opts[:teams])
  end

  defp parse_year(opts) do
    opts[:year]
  end

  def download_tables_to_csv(teams, _year) do
    create_download_dir()
    IO.inspect teams
    case teams do
      ["all"] -> Teams.get_all_team_names() |> Enum.map(fn x -> spawn(Scores.Teams, :table_to_csv, [x]) end)
      _       -> Enum.map(teams, fn x -> spawn(Scores.Teams, :table_to_csv, [x]) end)
    end
  end

  defp create_download_dir do
    case File.mkdir(@download_base_dir) do
      {:error, :eexist} -> L.log(:warn, "#{@download_base_dir} dir already exists")
      _                 -> L.log(:info, "#{@download_base_dir} dir created")
    end
  end

  def show_team_names_map do
    IO.puts IO.ANSI.light_cyan <> "Check below for the team code to use."
    IO.puts IO.ANSI.light_green <> "TEAM NAME | " <> IO.ANSI.light_magenta <> "TEAM CODE\n"
    Enum.map(Scores.Teams.get_all_team_names, fn x ->
      for {key, val} <- x do
        key = IO.ANSI.light_green <> Atom.to_string(key) |> String.pad_trailing(29)
        val = IO.ANSI.light_magenta <> val
        IO.puts "\t#{key} -> #{val}"
      end
    end)
  end
end

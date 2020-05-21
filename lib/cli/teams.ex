defmodule Scores.CLI.Teams do
  @moduledoc """
  Usage:
    scores --team <team> --year <year>

  Arguments --
    teams // returns a keyword list of full team name and a team code to be used
    download // pass in a team code and year to download year or years of team stats.
  """
  @download_base_dir Application.fetch_env!(:scores, :download_path)
  @max_concurrency System.schedulers_online() * 2
  @timeout 20000

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
    [arg | []] = args
    case arg do
      "teams"    -> show_team_names_map()
      "download" -> download_tables_to_csv(parse_teams(opts), parse_year(opts))
      _          -> L.error("'#{args}' not a valid command", ansi_color: IO.ANSI.red)
    end
  end

  defp parse_teams(opts) do
    opts[:teams]
    |> String.split()
  end

  defp parse_year(opts) do
    opts[:year]
  end

  def download_tables_to_csv(teams, year) do
    create_download_dir()
    run_download(teams, year)
  end

  defp run_download(["all"], year) do
    for team <- Teams.get_all_team_names() do
      Keyword.values(team) |> Enum.at(0)
    end
    |> Task.async_stream(
      Scores.Teams,
      :table_to_csv,
      [year],
      timeout: @timeout,
      max_concurrency: @max_concurrency,
      ordered: false
    )
    |> Stream.run
  end

  defp run_download(teams, year) do
    Task.async_stream(
      teams,
      Scores.Teams,
      :table_to_csv,
      [year],
      timeout: @timeout,
      max_concurrency: @max_concurrency,
      ordered: false
    )
    |> Stream.run
  end

  defp create_download_dir do
    case File.mkdir(@download_base_dir) do
      {:error, :eexist} -> L.log(:warn, "#{@download_base_dir} dir already exists")
      _                 -> L.log(:info, "#{@download_base_dir} dir created")
    end
  end

  def show_team_names_map do
    IO.puts IO.ANSI.light_cyan <> "Check below for the team code to use."
    IO.puts IO.ANSI.light_green <> "\tTEAM NAME | " <> IO.ANSI.light_magenta <> "TEAM CODE\n"
    Enum.map(Scores.Teams.get_all_team_names, fn x ->
      for {key, val} <- x do
        key = IO.ANSI.light_green <> Atom.to_string(key) |> String.pad_trailing(29)
        val = IO.ANSI.light_magenta <> val
        IO.puts "\t#{key} -> #{val}"
      end
    end)
  end
end

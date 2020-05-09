defmodule Scores do
  @fields ~w(age g mp fg_pct avg_dist fg2a_pct_fga pct_fga_00_03 pct_fga_03_10 pct_fga_10_16 pct_fga_16_xx fg3a_pct_fga fg2_pct fg_pct_00_03 fg_pct_03_10 fg_pct_10_16 fg_pct_16_xx fg3_pct fg2_pct_ast pct_fg2_dunk fg2_dunk fg3_pct_ast pct_fg3a_corner fg3_pct_corner fg3a_heave fg3_heave)
  @test_url "https://www.basketball-reference.com/teams/CHI/1998.html"

  alias Scores.Tables

  @moduledoc """
  Documentation for `Scores`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Scores.hello()
      :world

  """
  def main() do
    filename = "bulls_all_shooting_1998.csv"
    field_headers = [ "player" | @fields ]

    table_tokens = get_html_page()
    # |> get_scores_table()

    table_values = Enum.zip([parse_players_names(table_tokens) | get_all_attribs(table_tokens)])
    |> Enum.map(&(Tuple.to_list(&1)))

    to_csv([field_headers, table_values], filename)
  end

  def get_html_page() do
    case HTTPoison.get("https://www.basketball-reference.com/teams/CHI/1998.html") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        remove_html_comments(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "url not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def remove_html_comments(html_string), do: String.replace html_string, ~r/<!--|-->/, ""


  def parse_players_names(tokens) do
    names = Floki.find(tokens, "[data-stat=player] a")
    Enum.map(names, fn x ->
      {"a", [_], [name]} = x
      name
    end)
  end

  def parse_document(html) do
    case Floki.parse_document(html) do
      {:ok, html}     -> html
      {error, reason} -> {error, reason}
    end
  end

  def find_table_headers() do
    Tables.get_all_tables(@test_url)
    # |> Floki.find("thead tr")
  end

  def get_all_attribs(tokens) do
    for item <- @fields do
      values = Floki.find(tokens, "[data-stat=#{item}]")
      |> Enum.map(fn x ->
        case x do
          {"td", _, [val]} -> val
          {"th", _, [_]}   -> ""
          _                -> ""
        end
      end)
      Enum.filter values, &(&1 != "")
    end
  end

  def to_csv([headers, values], filename) do
    data = Enum.map([headers | values], &(Enum.join &1, ","))
    |> Enum.join("\n")

    case File.write filename, data do
      :ok -> IO.puts "wrote to `#{filename}`"
      err -> IO.puts err, "error writing to scores.csv"
    end
  end
end

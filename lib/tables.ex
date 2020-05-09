defmodule Scores.Tables do
  alias Scores.Utils

  def main do
    for team <- Utils.get_all_team_names do
      spawn(Scores.Tables, :get_table_cols, [team])
    end

  end

  def get_all_tables(url) do
    Utils.get_html_tokens(url)
    |> Floki.attribute("div", "id")
    |> extract_table_names()
  end

  def get_table_cols(team) do
    team = "CHI"
    tokens = create_team_url(team)
    |> Utils.get_html_tokens()

    table_names = tokens
    |> Floki.attribute("div", "id")
    |> extract_table_names
    IO.inspect table_names
    for table <- table_names do
      Floki.find(tokens, "##{table}")
      |> correct_tables(table)
      # |> Floki.find("div div table thead tr th")
      # |> Floki.find("div .thead th")
      # |> Floki.attribute("data-stat")
    end
  end

  def correct_tables(tokens, "all_salaries2") do
    Floki.find(tokens, "div .thead th")
    |> Floki.attribute("data-stat")
  end

  def correct_tables(tokens, "all_assistant_coaches") do
    Floki.find(tokens, "div tr td a")
    ["assistant_coach"]
  end

  def correct_tables(tokens, table) do
    Floki.find(tokens, "div div table thead tr th")
    |> Floki.attribute("data-stat")

  end

  defp inspector(tokens) do
    IO.inspect tokens
    tokens
  end
  def create_team_url(team, year \\ "1998") do
    url = "https://www.basketball-reference.com/teams/#{team}/#{year}.html"
    IO.puts url
    url
  end
  def extract_table_names(list), do: Enum.filter(list, &(String.starts_with?(&1, "all")))

end

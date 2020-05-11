defmodule Scores.Tables do
  alias Scores.{Utils, Teams}

  def main do
    for team <- Teams.get_all_team_names do
      spawn(Scores.Tables, :get_table_cols, [team])
    end

  end

  def get_all_tables(url) do
    Utils.get_html_tokens(url)
    |> Floki.attribute("div", "id")
    |> extract_table_names()
  end

  def correct_tables(tokens, "all_salaries2") do
    Floki.find(tokens, "div .thead th")
    |> Floki.attribute("data-stat")
  end

  def correct_tables(_tokens, "all_assistant_coaches") do
    ["assistant_coach"]
  end

  def correct_tables(tokens, _table) do
    Floki.find(tokens, "div div table thead tr th")
    |> Floki.attribute("data-stat")

  end

  def extract_table_names(list), do: Enum.filter(list, &(String.starts_with?(&1, "all")))
end

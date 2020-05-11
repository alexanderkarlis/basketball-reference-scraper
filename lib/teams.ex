defmodule Scores.Teams do
  @url_teams Application.fetch_env!(:scores, :teams)

  alias Scores.{Utils,Tables}

  def get_all_team_names() do
    Utils.get_html_tokens(@url_teams)
    |> Floki.find("#div_teams_active")
    |> Floki.find("[data-stat=franch_name]")
    |> Enum.drop(1)
    |> Enum.map(fn x ->
      case x do
        {"th", _, href_row} -> Floki.attribute(href_row, "href") |> team_name_href()
        _ -> "no match"
      end
    end)
  end

  def get_table_cols(_team) do
    team = "CHI"
    tokens = Utils.create_team_url(team)
    |> Utils.get_html_tokens()

    table_names = tokens
    |> Floki.attribute("div", "id")
    |> Tables.extract_table_names

    for table <- table_names do
      Floki.find(tokens, "##{table}")
      |> Tables.correct_tables(table)
    end
  end

  def team_name_href([name]) do
    String.split(name, "/") |> Enum.at(2)
  end

end

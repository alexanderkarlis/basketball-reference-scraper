defmodule Scores.Utils do
  @url "https://www.basketball-reference.com/teams/CHI/1998.html"
  @url_teams Application.fetch_env!(:scores, :teams)

  def get_html_tokens(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        File.write "output.html", body
        remove_html_comments(body)
        |> parse_document
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "url not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def remove_html_comments(html_string), do: String.replace html_string, ~r/<!--|-->/, ""

  def parse_document(html) do
    case Floki.parse_document(html) do
      {:ok, html}     -> html
      {error, reason} -> {error, reason}
    end
  end

  def get_all_team_names() do
    get_html_tokens(@url_teams)
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

  def team_name_href([name]) do
    String.split(name, "/") |> Enum.at(2)
  end

  def get_team_url(team_name) do
    case HTTPoison.get("https://www.basketball-reference.com/teams/#{team_name}/") do
      {:ok, %HTTPoison.Response{status_code: 200}} -> IO.puts "#{team_name} worked!"
      _ -> IO.puts ":("
    end
  end

end

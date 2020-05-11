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

  def create_team_url(team, year \\ "1998") do
    url = "https://www.basketball-reference.com/teams/#{team}/#{year}.html"
    IO.puts url
    url
  end

  def get_team_url(team_name) do
    case HTTPoison.get("https://www.basketball-reference.com/teams/#{team_name}/") do
      {:ok, %HTTPoison.Response{status_code: 200}} -> IO.puts "#{team_name} worked!"
      _ -> IO.puts ":("
    end
  end

end

defmodule Scores.Utils do
  @url_teams Application.fetch_env!(:scores, :teams)

  require Logger
  alias Logger, as: L

  def get_html_tokens(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        remove_html_comments(body)
        |> parse_document
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        L.warn("#{url} not found", ansi_color: IO.ANSI.yellow)
      {:error, %HTTPoison.Error{reason: reason}} ->
        L.error(reason, ansi_color: IO.ANSI.red)
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
    url = "#{@url_teams}#{team}/#{year}.html"
    L.info(url, ansi_color: IO.ANSI.green)
    url
  end
end

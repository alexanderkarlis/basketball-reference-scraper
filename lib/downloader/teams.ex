defmodule Scores.Downloader.Teams do
  @url_teams Application.fetch_env!(:scores, :teams)
  @filter_criteria ["" | ~w(DUMMY)]
  @download_base_dir Application.fetch_env!(:scores, :download_path)

  alias Scores.{Utils,Tables}

  def download_tables_to_csv() do
    get_all_team_names()
    |> Enum.map(fn x -> spawn(Scores.Downloader.Teams, :table_to_csv, [x]) end)
  end

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

  def get_table_cols(team) do
    tokens = Utils.create_team_url(team) |> Utils.get_html_tokens()
    table_names = Tables.get_all_tables(tokens, "tokens")

    parsed_tables = extract_table_cols(tokens, table_names)
    x = Enum.zip(table_names, parsed_tables)
    get_all_attrib_values tokens, x
  end

  def extract_table_cols(tokens, table_names) do
    for table <- table_names do
      Floki.find(tokens, "##{table}")
      |> Tables.correct_tables(table)
      |> Enum.filter(&(&1 not in @filter_criteria))
    end
  end

  def get_all_attrib_values(tokens, parsed_tables) do
    for {table, cols} <- parsed_tables do
      tokens = Floki.find(tokens, "##{table}")
      values = Enum.map(cols, fn col -> get_data(tokens, col) end)
      {table, Enum.zip(cols, values)}
    end
  end

  def table_to_csv(team) do
    get_table_cols(team)
    |> Enum.map(&(form_csv(&1, team)))
  end

  def form_csv({table_name, data}, team) do
    File.mkdir(@download_base_dir)
    File.mkdir("#{@download_base_dir}/#{team}")
    filename = "#{@download_base_dir}/#{team}/#{table_name}.csv"
    cols = []
    columns = Enum.map(data, fn {col, _values} -> [col | cols] end) |> Enum.flat_map(fn x -> x end)
    File.write(filename, Enum.join(columns, ", "))
    value_set = Enum.map(data, fn {_cols, values} -> values end)
    |> Enum.zip
    |> Enum.reduce("", fn x, line -> line <> "\n" <> Enum.join(Tuple.to_list(x), ", ") end)
    File.write(filename, value_set, [:append])
  end

  def get_data(tokens, "salary") do
    Floki.find(tokens, "[data-stat=salary]")
    |> Enum.map(&(Floki.text(&1)))
    |> Enum.drop(1)
    |> Enum.map(&(String.replace(&1, ~r/\$|,+/, "")))
  end

  def get_data(tokens, "birth_date") do
    Floki.find(tokens, "[data-stat=birth_date]")
    |> Enum.map(&(Floki.text(&1)))
    |> Enum.drop(1)
    |> Enum.map(&(convert_date(&1)))
  end

  def get_data(tokens, "college") do
    Floki.find(tokens, "[data-stat=college]")
    |> Enum.map(&(Floki.text(&1)))
    |> Enum.drop(1)
    |> Enum.map(&(Enum.at(String.split(&1, ", "), -1)))
  end

  def get_data(tokens, col) do
    Floki.find(tokens, "[data-stat=#{col}]")
    |> Enum.map(&(Floki.text(&1)))
    |> Enum.drop(1)
    |> Enum.map(fn x ->
      case Float.parse(x) do
        {integer, rem} when rem == "" -> integer
        {float, _rem}                 -> float
        :error -> check_string(x)
      end
    end)
  end

  def check_string(val) do
    stringed_val = String.pad_leading(val, String.length(val) + 1, "0")
    try do
      String.to_float(stringed_val)
    rescue
      ArgumentError -> val
    end
  end

  defp convert_date(date) do
    case Timex.parse date, "%B %e, %Y", :strftime do
      {:ok, datetime} -> Timex.format! datetime, "{YYYY}-{0M}-{D}"
      _               -> "0000-00-00"
    end
  end

  def team_name_href([name]) do
    String.split(name, "/") |> Enum.at(2)
  end

end

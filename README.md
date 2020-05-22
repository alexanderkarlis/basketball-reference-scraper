# Basketball Scores

**This repo is a web scraper for [Basketball Reference](https://www.basketball-reference.com)**


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `scores` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:scores, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/scores](https://hexdocs.pm/scores).

## Build & Configure
In order to set the desired download directory -> `export BBALL_DATA_PATH=/path/to/dir`
Default download directory is set to `./data`.

You can run `mix escript.build` to build the binary to use the functionality that this module exposes. 

### Examples
The download argument can either take an "all" option or a quoted number of team codes (see the `teams` argument).

The teams argument returns a list of teams and codes. And the year argument takes a single year to get data for. 
```
./scores download --teams CHI --year 2012
./scores download --teams "CHI NYK PHI" --year 1998
./scores teams
./scores --help
```

## Todos
- [x] /teams/<team> table scraper
- [x] incorporate CLI
- [x] add a get all team options
- [] make the CLI able to give a range of years
- [] update scraper to download files into separate years
- [] incorporate Ecto to have option to put into postgres
- [] use RabbitMQ to start a pipeline of other sports scrapers to better monitor
...

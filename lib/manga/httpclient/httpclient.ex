defmodule Manga.HttpClient do
  use Application
  alias Manga.HttpClient.{Sup, Fetcher}

  @default_user_agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"
  @default_options [
    follow_redirects: true,
    timeout: 10 * 1500,
    headers: [
      "User-Agent": @default_user_agent
    ]
  ]
  def start(_type, _args) do
    case Sup.start_link() do
      {:ok, pid} -> {:ok, pid}
      other -> {:error, other}
    end
  end

  def get(url, options \\ @default_options) do
    options =
      if options != @default_options do
        Keyword.merge(@default_options, options)
      else
        @default_options
      end

    {:ok, pid} = Fetcher.create(url, options)
    Fetcher.get(pid, url, options)
  end
end

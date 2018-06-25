defmodule Manga.HttpClient do
  alias Manga.HttpClient.{Worker}

  @default_user_agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"
  @default_options [
    follow_redirects: true,
    timeout: 10 * 1500,
    headers: [
      "User-Agent": @default_user_agent
    ]
  ]

  def get(url, options \\ @default_options) do
    options =
      if options != @default_options do
        Keyword.merge(@default_options, options)
      else
        @default_options
      end

    {:ok, pid} = Worker.create(url, options)
    Worker.get(pid, url, options)
  end
end

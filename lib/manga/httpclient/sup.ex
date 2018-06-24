defmodule Manga.HttpClient.Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(url, opts) do
    Supervisor.start_child(__MODULE__, [url, opts])
  end

  def init([]) do
    fetcher =
      worker(
        Manga.HttpClient.Fetcher,
        [],
        restart: :temporary,
        shutdown: :brutal_kill
      )

    children = [fetcher]
    supervise(children, strategy: :simple_one_for_one, max_restarts: 0, max_seconds: 1)
  end
end

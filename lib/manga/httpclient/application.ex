defmodule Manga.HttpClient.Application do
  use Application
  alias Manga.HttpClient.{Reque}

  def start(_type, _args) do
    Reque.init()

    opts = [
      name: Manga.HttpClient.Supervisor,
      strategy: :one_for_one,
      max_children: 5
    ]

    DynamicSupervisor.start_link(opts)
  end
end

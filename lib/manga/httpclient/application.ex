defmodule Manga.HttpClient.Application do
  use Application

  def start(_type, _args) do
    opts = [name: Manga.HttpClient.Supervisor, strategy: :one_for_one]
    DynamicSupervisor.start_link(opts)
  end
end

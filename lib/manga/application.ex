defmodule Manga.Application do
  use Application

  def start(_type, _args) do
    Manga.HttpClient.start(:normal, [])
  end
end

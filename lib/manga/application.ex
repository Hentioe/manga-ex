defmodule Manga.Application do
  use Application

  def start(_type, _args) do
    Manga.HttpClient.Application.start(:normal, [])
  end
end

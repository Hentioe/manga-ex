defmodule Manga.HttpClient.Fetcher do
  use GenServer
  alias Manga.HttpClient.{Sup}

  def start_link(url, opts) do
    GenServer.start_link(__MODULE__, [url, opts])
  end

  def init(state) do
    {:ok, state}
  end

  def create(url, options) do
    Sup.start_child(url, options)
  end

  def get(pid, url, options) do
    GenServer.cast(pid, {:get, {url, options, self()}})
  end

  def handle_cast({:get, {url, options, from}}, state) do
    send(from, {:fetched, {url, HTTPotion.get(url, options)}})
    {:noreply, state}
  end
end

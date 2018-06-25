defmodule Manga.HttpClient.Worker do
  use GenServer

  def start_link({url, opts}) do
    GenServer.start_link(__MODULE__, [url, opts])
  end

  def init(state) do
    {:ok, state}
  end

  def create(url, options) do
    child_spec = {Manga.HttpClient.Worker, {url, options}}
    DynamicSupervisor.start_child(Manga.HttpClient.Supervisor, child_spec)
  end

  def get(pid, url, options) do
    GenServer.cast(pid, {:get, {url, options, self()}})
  end

  def handle_cast({:get, {url, options, from}}, state) do
    send(from, {:fetched, {url, HTTPotion.get(url, options)}})
    {:noreply, state}
  end
end

defmodule Manga.Utils.Props do
  import Manga.Utils.Printer
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  defp put(name, value) do
    Agent.update(__MODULE__, fn props -> Map.put(props, name, value) end)
  end

  def get(name) when is_binary(name) do
    Agent.get(__MODULE__, fn props -> Map.get(props, name) end)
  end

  def get_all do
    Agent.get(__MODULE__, fn props -> props end)
  end

  @key_fd "fd"
  def set_fd(millisecond) do
    millisecond = if millisecond == nil, do: 0, else: millisecond

    if !is_integer(millisecond) do
      case Integer.parse(millisecond) do
        {n, _} ->
          put(@key_fd, n)

        {:error} ->
          print_warring("[props:fd] is not a number")
          put(@key_fd, 0)
      end
    else
      put(@key_fd, millisecond)
    end
  end

  def get_fd do
    get(@key_fd)
  end

  @key_dd "dd"
  def set_dd(millisecond) do
    millisecond = if millisecond == nil, do: 0, else: millisecond

    if !is_integer(millisecond) do
      case Integer.parse(millisecond) do
        {n, _} ->
          put(@key_dd, n)

        {:error} ->
          print_warring("[props:dd] is not a number")
          put(@key_dd, 0)
      end
    else
      put(@key_dd, millisecond)
    end
  end

  def get_dd do
    get(@key_dd)
  end

  @key_url "url"
  def set_url(url) do
    put(@key_url, url)
  end

  def get_url do
    get(@key_url)
  end
end

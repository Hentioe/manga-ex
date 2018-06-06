defmodule Manga.Utils.Props do
  import Manga.Utils.Printer
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  defp put(name, value) do
    Agent.update(__MODULE__, fn props -> Map.put(props, name, value) end)
  end

  def get(name, default \\ nil) when is_binary(name) do
    Agent.get(__MODULE__, fn props -> Map.get(props, name, default) end)
  end

  def get_all do
    Agent.get(__MODULE__, fn props -> props end)
  end

  defp set_number(key, value, default \\ 0) do
    value = if value == nil, do: 0, else: value

    if !is_integer(value) do
      case Integer.parse(value) do
        {n, _} ->
          put(key, n)

        {:error} ->
          print_warring("[props:#{key}] is not a number")
          put(key, default)
      end
    else
      put(key, value)
    end
  end

  defp get_number(key, default \\ 0) do
    case get(key) do
      nil -> default
      v -> v
    end
  end

  def set_delay(delay_list) when is_binary(delay_list) do
    get_delay = fn ns ->
      delay_str = String.slice(ns, 1, String.length(ns))
      case String.at(ns, 0) do
        "f" ->
          {:f, delay_str}

        "d" ->
          {:d, delay_str}
      end
    end

    delay_list
    |> String.split(",")
    |> Enum.filter(fn ns -> String.trim(ns, " ") != "" end)
    |> Enum.each(fn ns ->
      case get_delay.(ns) do
        {:f, delay} -> set_fetch_delay(delay)
        {:d, delay} -> set_download_delay(delay)
      end
    end)
  end

  @key_fetch_delay "fetch_delay"
  def set_fetch_delay(millisecond), do: set_number(@key_fetch_delay, millisecond)

  def get_fetch_delay, do: get_number(@key_fetch_delay)

  @key_download_delay "download_delay"
  def set_download_delay(millisecond), do: set_number(@key_download_delay, millisecond)

  def get_download_delay, do: get_number(@key_download_delay)
end

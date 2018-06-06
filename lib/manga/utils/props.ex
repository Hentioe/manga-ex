defmodule Manga.Utils.Props do
  import Manga.Utils.Printer
  use Agent

  @key_mac_string "mac_string"
  def start_link(_opts) do
    props = %{
      @key_mac_string => get_mac_string()
    }

    Agent.start_link(fn -> props end, name: __MODULE__)
  end

  @key_more "more_count"
  def init_more(module) do
    put(@key_more, {module, 0})
  end

  def get_and_more do
    case get(@key_more) do
      {module, count} ->
        next = count + 1
        put(@key_more, {module, next})
        next

      _ ->
        1
    end
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

  def set_delay(_), do: nil

  def get_mac_string do
    {:ok, nlist} = :inet.getifaddrs()

    mac_list =
      nlist
      |> Enum.map(fn {_, address_list} ->
        case address_list do
          [flags: _, hwaddr: hwaddr, addr: _, netmask: _, broadaddr: _, addr: _, netmask: _] ->
            hwaddr

          _ ->
            nil
        end
      end)
      |> Enum.filter(fn hwaddr -> hwaddr != nil end)
      |> List.first()
      |> Enum.map(fn n ->
        Integer.to_string(n, 16)
      end)

    mac_list |> List.to_string()
  end

  def get_operator, do: get(@key_mac_string, "UNKNOWN")

  @key_fetch_delay "fetch_delay"
  def set_fetch_delay(millisecond), do: set_number(@key_fetch_delay, millisecond)

  def get_fetch_delay, do: get_number(@key_fetch_delay)

  @key_download_delay "download_delay"
  def set_download_delay(millisecond), do: set_number(@key_download_delay, millisecond)

  def get_download_delay, do: get_number(@key_download_delay)
end

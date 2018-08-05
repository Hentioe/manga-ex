defmodule Manga.Utils.Props do
  @moduledoc false

  alias Manga.{Printer}

  @table :props
  @key_mac_string "mac_string"
  @key_more "more_count"
  @key_fetch_delay "fetch_delay"
  @key_download_delay "download_delay"
  @key_os_type "os_type"

  def init_table do
    :ets.new(@table, [:named_table])
    put(@key_mac_string, get_mac_string())
    put(@key_os_type, get_os_type())
  end

  def put(name, value) do
    :ets.insert(@table, {name, value})
  end

  def get(name, default \\ nil) when is_binary(name) do
    case :ets.lookup(@table, name) do
      [{^name, value}] -> value
      [] -> default
    end
  end

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

  def set_number(key, value, default \\ 0) do
    value = if value == nil, do: 0, else: value

    if is_integer(value) do
      put(key, value)
    else
      case Integer.parse(value) do
        {n, _} ->
          put(key, n)

        {:error} ->
          Printer.get_current_printer().echo_warning("[props:#{key}] is not a number")
          put(key, default)
      end
    end
  end

  def get_number(key, default \\ 0) do
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
    |> Enum.each(
         fn ns ->
           case get_delay.(ns) do
             {:f, delay} -> set_fetch_delay(delay)
             {:d, delay} -> set_download_delay(delay)
           end
         end
       )
  end

  def set_delay(_), do: nil

  def get_mac_string do
    {:ok, nlist} = :inet.getifaddrs()

    nlist
    |> Enum.map(fn {_, address_list} -> address_list end)
    |> Enum.filter(fn address_list -> address_list[:hwaddr] != nil end)
    |> Enum.map(
         fn address_list ->
           address_list[:hwaddr]
           |> Enum.map(
                fn hw_unit ->
                  Integer.to_string(hw_unit, 16)
                end
              )
           |> List.to_string()
         end
       )
    |> Enum.filter(
         fn address ->
           case address do
             "000000" -> false
             _ -> true
           end
         end
       )
    |> List.first()
  end

  defp get_os_type do
    {_, name} = :os.type()
    name
  end

  def get_operator, do: get(@key_mac_string, "UnKnown")

  def set_fetch_delay(millisecond), do: set_number(@key_fetch_delay, millisecond)

  def get_fetch_delay, do: get_number(@key_fetch_delay)

  def set_download_delay(millisecond), do: set_number(@key_download_delay, millisecond)

  def get_download_delay, do: get_number(@key_download_delay)

  def get_os_name, do: get(@key_os_type, :unknow_os)
end

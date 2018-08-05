defmodule Manga.Utils.IOUtils do
  @moduledoc false

  def mkdir_not_exists(path_list) when is_list(path_list) do
    Enum.each(path_list, fn path ->
      if !File.exists?(path) do
        File.mkdir(path)
      end
    end)
  end

  def mkdir_not_exists(path) do
    mkdir_not_exists([path])
  end

  def gets(text) do
    IO.gets("#{IO.ANSI.color(255)}#{text}")
  end

  def gets_number(text) do
    text = gets(text)

    text
    |> String.trim()
    |> Integer.parse()
  end

  # 通过用户输入的区间和列表构造出完整的数字列表
  def gets_numbers(text) do
    text = gets(text)

    text
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn nrage ->
      String.trim(nrage)
    end)
    |> Enum.map(fn nrange ->
      if String.contains?(nrange, "-") do
        start_and_end =
          nrange
          |> String.trim()
          |> String.split("-")
          |> Enum.map(fn nstr ->
            case nstr |> String.trim() |> Integer.parse() do
              {n, _} -> n
              :error -> nil
            end
          end)
          |> Enum.filter(fn n -> n != nil end)

        (start_and_end |> List.first())..(start_and_end |> List.last())
        |> Enum.to_list()
      else
        case Integer.parse(nrange) do
          {n, _} ->
            [n]

          :error ->
            nil
        end
      end
    end)
    |> Enum.filter(fn n -> n != nil end)
    |> expansion_sub_list()
    |> Enum.uniq()
  end

  defp expansion_sub_list(rlist, elist \\ [], n \\ 0) do
    if n == length(rlist) do
      elist
    else
      expansion_sub_list(rlist, elist ++ Enum.at(rlist, n), n + 1)
    end
  end
end

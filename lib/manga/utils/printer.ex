defmodule Manga.Utils.Printer do
  def print_info(text) do
    "#{IO.ANSI.color(8)}#{text}" |> IO.puts()
  end

  def print_result(text) do
    "#{IO.ANSI.blue()}#{text}" |> IO.puts()
  end

  def print_error(error) do
    "#{IO.ANSI.red()}[Error] #{error}\n" |> (&IO.write(:stderr, &1)).()
  end

  def print_normal(text) do
    "#{IO.ANSI.white()}#{text}" |> IO.puts()
  end

  def newline do
    "\n" |> (&IO.write(:stdio, &1)).()
  end

  def print_warning(text) do
    IO.puts("#{IO.ANSI.yellow()}[Warning] #{text}")
  end
end

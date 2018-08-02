defmodule Manga.Printer.LinuxPrinter do
  use Manga.Printer

  def gen_normal_text(text) do
    text
  end

  def gen_info_text(text) do
    "#{IO.ANSI.color(8)}#{text}"
  end

  def gen_result_text(text) do
    "#{IO.ANSI.blue()}#{text}"
  end

  def gen_error_text(error) do
    "#{IO.ANSI.red()}[Error] #{error}\n"
  end

  def gen_warning_text(text) do
    "#{IO.ANSI.yellow()}[Warning] #{text}"
  end
end

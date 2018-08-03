defmodule Manga.Printer.WindowsPrinter do

  @moduledoc false

  use Manga.Printer

  def gen_normal_text(text) do
    text
  end

  def gen_info_text(text) do
    text
  end

  def gen_result_text(text) do
    text
  end

  def gen_error_text(error) do
    "[Error] #{error}"
  end

  def gen_warning_text(text) do
    "[Warning] #{text}"
  end
end

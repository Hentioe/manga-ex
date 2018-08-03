defmodule Manga.Exporter.PdfExporter do

  @moduledoc false

  use Manga.Exporter

  def save_from_stage(stage) do
    epub_file = "./_res/EPUBs/#{stage.name}.epub"
    output_file = "./_res/PDFs/#{stage.name}.pdf"

    if !File.exists?(epub_file) do
      {:error, "EPUB template not exists"}
    else
      case System.cmd("ebook-convert", [epub_file, output_file], stderr_to_stdout: true) do
        {_, 0} -> {:ok, output_file}
        error -> {:error, "Converter:#{stage.name} ebook-convert: #{error}"}
      end
    end
  end
end

defmodule Manga.Utils.Downloader do
  import Manga.Utils.IOUtils
  import Manga.Utils.Printer

  @base_path "./_res"
  @assets_path "#{@base_path}/assets"
  @cache_path "#{@base_path}/.cache"
  @output_path_epub "#{@base_path}/EPUBs"
  @output_path_mobi "#{@base_path}/MOBIs"
  @output_path_pdf "#{@base_path}/PDFs"

  @on_load :init_assets_path

  def from(address, options \\ []) do
    Download.from(address, options)
  end

  def from_page(stage, page) do
    dir_name = "#{@assets_path}/#{stage.name}"
    mkdir_not_exists(dir_name)

    case from(
           page.url,
           path: "#{dir_name}/#{page.p}.jpg",
           headers: page.http_headers,
           options: page.http_options
         ) do
      {:ok, path} ->
        print_info("[Saved] #{path}")
        {:ok, path}

      error ->
        error
    end
  end

  def from_stage(stage) do
    dir_name = "#{@assets_path}/#{stage.name}"

    mkdir_not_exists(dir_name)

    print_info("[Extracting] #{stage.name}")

    rlist =
      stage.plist
      |> Enum.map(fn page ->
        print_info("[Downloading] #{stage.name}-#{page.p}P")
        stage |> from_page(page)
      end)

    {:ok, rlist}
  end

  def init_assets_path do
    mkdir_not_exists([
      @base_path,
      @assets_path,
      @cache_path,
      @output_path_epub,
      @output_path_mobi,
      @output_path_pdf
    ])
  end
end

defmodule Manga.Utils.Downloader do
  import Manga.Utils.IOUtils
  import Manga.Utils.ProgressBar
  alias Manga.Utils.Props

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

    from(
      page.url,
      path: "#{dir_name}/#{page.p}.#{page.suffix}",
      headers: page.http_headers,
      options: page.http_options
    )
  end

  def from_stage(stage) do
    dir_name = "#{@assets_path}/#{stage.name}"

    mkdir_not_exists(dir_name)
    total = length(stage.plist)

    rlist =
      stage.plist
      |> Enum.with_index()
      |> Enum.map(fn {page, i} ->
        stage
        |> from_page(page)

        :timer.sleep(Props.get_download_delay())
        render_download(stage.name, i + 1, total)
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

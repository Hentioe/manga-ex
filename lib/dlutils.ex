defmodule Manga.DLUtils do
  @assets_path "./assets"
  @on_load :init_assets_path

  def from(address, options \\ []) do
    Download.from(address, options)
  end

  def from_page(stage, page) do
    dir_name = "#{@assets_path}/#{stage.name}"
    mkdir_not_exists?([dir_name])

    case from(page.url, path: "#{dir_name}/#{page.p}.jpg") do
      {:ok, path} ->
        IO.puts("[Saved] #{path}")

      {:error, error} ->
        {:error, error}
    end
  end

  def from_stage(stage, origin) do
    dir_name = "#{@assets_path}/#{stage.name}"

    mkdir_not_exists?([dir_name])

    IO.puts("\n[Extracting] #{stage.name}")

    case origin.fetch(stage) do
      {:ok, pages} ->
        pages
        |> Enum.each(fn page ->
          IO.puts("[Downloading] #{stage.name}-#{page.p}P")
          stage |> from_page(page)
        end)

      {:error, error} ->
        {:error, error}
    end
  end

  defp mkdir_not_exists?(path_list) do
    Enum.each(path_list, fn path ->
      if !File.exists?(path) do
        File.mkdir(path)
      end
    end)
  end

  def init_assets_path do
    mkdir_not_exists?([@assets_path])
  end
end

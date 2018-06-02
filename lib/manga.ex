defmodule Manga do
  import Manga.Utils.Printer

  @moduledoc """
  Documentation for Manga.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Manga.hello
      :world

  """
  def hello do
    :world
  end

  alias Manga.Model.Platform
  alias Manga.Utils.IOUtils

  @platforms [
    Platform.create(
      name: "风之动漫",
      origin: Manga.Res.FZDMOrigin
    )
  ]

  def main(args \\ []) do
    if(length(args) == 0) do
      # 如果没有参数则进入交互模式
      print_normal("Welcome to Manga.ex! Currently supported platform list:\n")

      @platforms
      |> Enum.with_index()
      |> Enum.each(fn {platform, i} ->
        print_result("[#{i + 1}]: #{platform.name}")
      end)

      {n, _} =
        IOUtils.gets("\nPlease select a platform, [Number]: ")
        |> String.trim()
        |> Integer.parse()

      Enum.at(@platforms, n - 1) |> index
    else
      _parsed = OptionParser.parse(args)
      args |> List.first() |> export()
    end
  end

  defp index(p) do
    case p.origin.index() do
      {:ok, list} ->
        list
        |> Enum.with_index()
        |> Enum.each(fn {manga_info, i} ->
          print_result("[#{i + 1}]: #{manga_info.name}")
        end)

        {n, _} = IOUtils.gets_number("\nPlease select a manga, [Number]: ")
        Enum.at(list, n - 1).url |> export()

      {:error, error} ->
        print_error(error)
    end
  end

  defp export(url) do
    cond do
      # 漫画主页（话/卷列表）
      url |> platform?(~r/https:\/\/manhua.fzdm.com\/\d+\/$/i) ->
        case Manga.Res.FZDMOrigin.stages(%Manga.Model.Info{url: url}) do
          {:ok, manga_info} ->
            list = manga_info.stage_list |> Enum.reverse()

            list
            |> Enum.with_index()
            |> Enum.each(fn {stage, i} ->
              print_result("[#{i}]: #{stage.name}")
            end)

            {n, _} = IOUtils.gets_number("\nPlease select a stage, [Number]: ")

            Enum.at(list, n).url |> export()

          {:error, error} ->
            print_error(error)
        end

      # 漫画页（某一话）
      url |> platform?(~r/https:\/\/manhua.fzdm.com\/\d+\/[^\/]+\//i) ->
        with {:ok, stage} <- Manga.Res.FZDMOrigin.fetch(%Manga.Model.Stage{url: url}),
             {:ok, _} <- Manga.Utils.Downloader.from_stage(stage),
             {:ok, path} <- Manga.Res.EpubExport.save_from_stage(stage) do
          # 输出结果
          print_result("[Saved] #{path}")
        else
          {:error, error} ->
            print_error(error)
        end

      true ->
        print_error("Unknown platform url")
    end
  end

  defp platform?(str, regex) do
    String.match?(str, regex)
  end
end

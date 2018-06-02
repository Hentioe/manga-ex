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

  use Manga.Res, :models
  alias Manga.Utils.IOUtils

  @platforms [
    dmzj:
      Platform.create(
        name: "动漫之家",
        origin: Manga.Res.DMZJOrigin
      ),
    fzdm:
      Platform.create(
        name: "风之动漫",
        origin: Manga.Res.FZDMOrigin
      )
  ]

  def main(args \\ []) do
    if(length(args) == 0) do
      # 如果没有参数则进入交互模式
      print_normal("Welcome to Manga.ex! Currently supported platform list:\n")

      list =
        @platforms
        |> Enum.map(fn {_, platform} -> platform end)
        |> Enum.with_index()
        |> Enum.map(fn {platform, i} ->
          print_result("[#{i + 1}]: #{platform.name}")
          platform
        end)

      {n, _} =
        IOUtils.gets("\nPlease select a platform, [Number]: ")
        |> String.trim()
        |> Integer.parse()

      Enum.at(list, n - 1) |> index
    else
      _parsed = OptionParser.parse(args)
      args |> List.first() |> export()
    end
  end

  defp index(p) do
    case p.origin.index() do
      {:ok, list} ->
        newline()

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
    case platform?(url) do
      # 待选择的(话/卷)列表
      {:stages, key} ->
        newline()

        case @platforms[key].origin.stages(Info.create(url: url)) do
          {:ok, manga_info} ->
            list =
              manga_info.stage_list
              |> Enum.with_index()
              |> Enum.map(fn {stage, i} ->
                print_result("[#{i + 1}]: #{stage.name}")
                stage
              end)

            {n, _} = IOUtils.gets_number("\nPlease select a stage, [Number]: ")

            Enum.at(list, n - 1).url |> export()

          {:error, error} ->
            print_error(error)
        end

      # 获取漫画内容（下载并保存）
      {:fetch, key} ->
        with {:ok, stage} <- @platforms[key].origin.fetch(Stage.create(url: url)),
             {:ok, _} <- Manga.Utils.Downloader.from_stage(stage),
             {:ok, path} <- Manga.Res.EpubExport.save_from_stage(stage) do
          # 输出结果
          print_result("[Saved] #{path}")
        else
          {:error, error} ->
            print_error(error)
        end

      {:error, error} ->
        print_error(error)
    end
  end

  defp platform?(url) do
    is_match = fn pattern -> Regex.match?(pattern, url) end

    cond do
      is_match.(~r/https:\/\/manhua.fzdm.com\/\d+\/$/i) ->
        {:stages, :fzdm}

      is_match.(~r/https:\/\/manhua.fzdm.com\/\d+\/[^\/]+\//i) ->
        {:fetch, :fzdm}

      is_match.(~r/https?:\/\/manhua.dmzj.com\/[^\/]+\/?$/i) ->
        {:stages, :dmzj}

      is_match.(~r/https:\/\/manhua.dmzj.com\/[^\/]+\/\d+\.shtml/i) ->
        {:fetch, :dmzj}

      true ->
        {:error, "Unknown platform url"}
    end
  end
end

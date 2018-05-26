defmodule Manga do
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

  def main(argv \\ []) do
    if(length(argv) == 0) do
      IO.puts("Arguments Error, Please input the resource URL")
    end

    argv |> List.first() |> export()
  end

  defp export(url) do
    cond do
      # 漫画主页（话/卷列表）
      url |> platform?(~r/https:\/\/manhua.fzdm.com\/\d+\/$/i) ->
        case Manga.Res.FZDMOrigin.stages(%Manga.Res.Info{url: url}) do
          {:ok, manga_info} ->
            manga_info.stage_list
            |> Enum.reverse()
            |> Enum.with_index()
            |> Enum.each(fn {v, i} ->
              IO.puts("[#{i}] #{v.name}")
            end)

          {:error, msg} ->
            IO.puts(msg)
        end

      # 漫画页（某一话）
      url |> platform?(~r/https:\/\/manhua.fzdm.com\/\d+\/\d+\//i) ->
        stages_url =
          Regex.scan(~r/https:\/\/manhua.fzdm.com\/\d+\//i, url)
          |> List.first()
          |> List.first()

        case Manga.Res.FZDMOrigin.stages(%Manga.Res.Info{url: stages_url}) do
          {:ok, manga_info} ->
            case manga_info.stage_list
                 |> Enum.filter(fn stage ->
                   stage.url == url
                 end)
                 |> List.first()
                 |> Manga.Res.FZDMOrigin.fetch() do
              {:ok, stage} ->
                # 下载资源
                case Manga.DLUtils.from_stage(stage) do
                  {:ok, _} ->
                    # 合并资源
                    case Manga.Res.EpubExport.save_from_stage(stage) do
                      {:ok, path} ->
                        IO.puts("[Saved] #{path}")

                      {:error, msg} ->
                        IO.inspect(msg)
                    end

                  {:error, msg} ->
                    IO.puts(msg)
                end

              {:error, msg} ->
                IO.puts(msg)
            end

          {:error, msg} ->
            IO.puts(msg)
        end

      true ->
        IO.puts("Unknown platform url")
    end
  end

  defp platform?(str, regex) do
    String.match?(str, regex)
  end
end

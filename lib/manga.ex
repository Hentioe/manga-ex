defmodule Manga do
  import Manga.PrintUtils

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
      print_error("Arguments Error, Please input the resource URL")
    else
      argv |> List.first() |> export()
    end
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
              print_result("[#{i}] #{v.name}")
            end)

          {:error, error} ->
            print_error(error)
        end

      # 漫画页（某一话）
      url |> platform?(~r/https:\/\/manhua.fzdm.com\/\d+\/[^\/]+\//i) ->
        with {:ok, stage} <- Manga.Res.FZDMOrigin.fetch(%Manga.Res.Stage{url: url}),
             {:ok, _} <- Manga.DLUtils.from_stage(stage),
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

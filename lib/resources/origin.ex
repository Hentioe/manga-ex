defmodule Manga.Res.Origin do
  @callback index(String.t()) :: {:ok, [Manga.Res.Info.t()]} | {:error, String.t()}
  @callback search(String.t()) :: {:ok, [Manga.Res.Info.t()]} | {:error, String.t()}
  @callback stages(Manga.Res.Info.t()) :: {:ok, Manga.Res.Info.t()} | {:error, String.t()}
  @callback fetch(Manga.Res.Stage.t()) :: {:ok, Manga.Res.Stage.t()} | {:error, String.t()}

  @spec fetchall(Manga.Res.Origin, Manga.Res.Info.t()) ::
          {:ok, [Manga.Res.Info.t()]} | {:error, String.t()}
  def fetchall(implementation, manga_info) do
    case implementation.stages(manga_info) do
      {:ok, list} ->
        list =
          Enum.map(list, fn stage ->
            {:ok, stage} = implementation.fetch(stage)
            stage
          end)

        manga_info = %{manga_info | stage_list: list}
        {:ok, manga_info}

      {:error, error} ->
        {:error, error}
    end
  end
end

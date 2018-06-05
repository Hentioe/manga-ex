defmodule Manga.Res.Export do
  @callback save_from_stage(Manga.Model.Stage.t()) :: {:ok, String.t()} | {:error, String.t()}
end

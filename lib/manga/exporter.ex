defmodule Manga.Res.Exporter do

  defmacro __using__(_otps) do
    quote do
      @behaviour Manga.Res.Exporter
    end
  end

  @callback save_from_stage(Manga.Model.Stage.t()) :: {:ok, String.t()} | {:error, String.t()}
end

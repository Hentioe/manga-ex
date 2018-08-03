defmodule Manga.Exporter do
  @moduledoc false

  defmacro __using__(_otps) do
    quote do
      @behaviour Manga.Exporter
    end
  end

  @callback save_from_stage(Manga.Model.Stage.t()) :: {:ok, String.t()} | {:error, String.t()}
end

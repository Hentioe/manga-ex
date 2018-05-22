defmodule Manga.Res.Origin do
  @callback search(String.t()) :: {:ok, term} | {:error, String.t()}
  @callback number_list(term) :: {:ok, term} | {:error, String.t()}
  @callback fetch(String.t()) :: {:ok, term} | {:error, String.t()}

  def fetchall(implementation, manga) do
    case implementation.number_list(manga) do
      {:ok, list} ->
        {:ok, list}

      {:error, error} ->
        {:error, error}
    end
  end
end

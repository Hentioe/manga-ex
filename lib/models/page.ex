defmodule Manga.Model.Page do
  defstruct [:p, :url]

  def create(props) do
    %__MODULE__{p: props[:p], url: props[:url]}
  end
end

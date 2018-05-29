defmodule Manga.Model.Page do
  defstruct [:p, :url]

  def create(props) when is_list(props) do
    %__MODULE__{p: props[:p], url: props[:url]}
  end
end

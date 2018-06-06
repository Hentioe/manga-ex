defmodule Manga.Model.Platform do
  defstruct [:name, :origin, :url]

  def create(props) do
    %__MODULE__{name: props[:name], origin: props[:origin], url: props[:url]}
  end

end

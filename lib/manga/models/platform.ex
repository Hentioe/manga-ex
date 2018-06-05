defmodule Manga.Model.Platform do
  defstruct [:name, :origin]

  def create(props) do
    %__MODULE__{name: props[:name], origin: props[:origin]}
  end

end

defmodule Manga.Model.Platform do

  @moduledoc false

  defstruct [:name, :origin, :url, :flags]

  def create(props) do
    %__MODULE__{
      name: props[:name],
      origin: props[:origin],
      url: props[:url],
      flags: props[:flags]
    }
  end
end

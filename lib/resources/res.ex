defmodule Manga.Res do
  def models do
    quote do
      alias Manga.Model.Platform
      alias Manga.Model.Info
      alias Manga.Model.Stage
      alias Manga.Model.Page
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

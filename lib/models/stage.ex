defmodule Manga.Model.Stage do
  defstruct [:name, :url, plist: []]

  def create(props) do
    plist = if(!props[:plist], do: [], else: props[:plist])
    %__MODULE__{name: props[:name], url: props[:url], plist: plist}
  end

  def rename(stage, name) do
    %{stage | name: name}
  end

  def update_plist(stage, plist) do
    %{stage | plist: plist}
  end

  def add_plist(stage, plist) when is_list(plist) do
    %{stage | plist: stage.plist ++ plist}
  end

  def add_page(stage, page) do
    add_plist(stage, [page])
  end
end

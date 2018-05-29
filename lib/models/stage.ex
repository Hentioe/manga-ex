defmodule Manga.Model.Stage do
  defstruct [:name, :url, plist: []]

  def create(props) when is_list(props) do
    plist = if(!props[:plist], do: [], else: props[:plist])
    %__MODULE__{name: props[:name], url: props[:url], plist: plist}
  end

  def rename(stage, name) when is_binary(name) do
    %{stage | name: name}
  end

  def update_plist(stage, plist) when is_list(plist) do
    %{stage | plist: plist}
  end

  def add_plist(stage, plist) when is_list(plist) do
    %{stage | plist: stage.plist ++ plist}
  end

  def add_page(stage, page) do
    add_plist(stage, [page])
  end
end

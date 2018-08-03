defmodule Manga.Model.Stage do

  @moduledoc false

  defstruct [:name, :url, :platform, plist: []]

  def create(props) when is_list(props) do
    plist = if(!props[:plist], do: [], else: props[:plist])
    %__MODULE__{name: props[:name], url: props[:url], platform: props[:platform], plist: plist}
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

  def set_platform(stage, platform) do
    %{stage | platform: platform}
  end
end

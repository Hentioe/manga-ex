defmodule Manga.Model.Info do

  @moduledoc false

  defstruct [:name, :url, stage_list: []]

  def create(props) when is_list(props) do
    stage_list = if(!props[:stage_list], do: [], else: props[:stage_list])
    %__MODULE__{name: props[:name], url: props[:url], stage_list: stage_list}
  end

  def rename(info, name) when is_binary(name) do
    %{info | name: name}
  end

  def update_stage_list(info, stage_list) when is_list(stage_list) do
    %{info | stage_list: stage_list}
  end

  def reverse_stage_list(info) do
    %{info | stage_list: info.stage_list |> Enum.reverse()}
  end

  def add_stage_list(info, stage_list) when is_list(stage_list) do
    %{info | stage_list: info.stage_list <> stage_list}
  end

  def add_stage(info, stage) do
    add_stage_list(info, [stage])
  end
end

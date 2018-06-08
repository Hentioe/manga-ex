defmodule Manga.Res.KKDMOriginTest do
  use ExUnit.Case
  import Manga.Res.KKDMOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 21
  end

  # test "stages" do
  #   {state, result} = stages(Info.create(url: "https://www.manhuagui.com/comic/18026/"))
  #   send(self(), state)
  #   assert_received :ok, result
  #   assert result.name != nil
  #   assert is_list(result.stage_list)
  #   assert length(result.stage_list) == 128
  # end

  # test "fetch" do
  #   {state, result} = fetch(Stage.create(url: "https://www.manhuagui.com/comic/2863/372981.html"))
  #   assert state == :ok
  #   assert result.name != nil
  #   assert is_list(result.plist)
  #   assert length(result.plist) == 21
  # end
end

defmodule Manga.Res.MHGOriginTest do
  use ExUnit.Case
  import Manga.Res.MHGOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  # test "index" do
  #   {state, result} = index(nil)
  #   assert state == :ok
  #   assert is_list(result)
  #   assert length(result) == 50
  # end

  # test "stages" do
  #   {state, result} = stages(Info.create(url: "https://www.manhuagui.com/comic/18026/"))
  #   send(self(), state)
  #   assert_received :ok, result
  #   assert result.name != nil
  #   assert is_list(result.stage_list)
  #   assert length(result.stage_list) == 128
  # end

  # test "fetch" do
  #   {state, result} = fetch(Stage.create(url: "http://www.dm5.com/m617894/"))
  #   assert state == :ok
  #   assert result.name != nil
  #   assert is_list(result.plist)
  #   assert length(result.plist) == 18
  # end
end

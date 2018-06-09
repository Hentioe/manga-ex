defmodule Manga.Res.HHMHOriginTest do
  use ExUnit.Case
  import Manga.Res.HHMHOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  # test "index" do
  #   {state, result} = index(1)
  #   assert state == :ok
  #   assert is_list(result)
  #   assert length(result) == 100
  # end

  # test "stages" do
  #   {state, result} = stages(Info.create(url: "http://www.hhmmoo.com/manhua31671.html"))

  #   send(self(), state)
  #   assert_received :ok, result
  #   assert result.name != nil
  #   assert is_list(result.stage_list)
  #   assert length(result.stage_list) == 19
  # end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "http://www.hhmmoo.com/page313258/1.html?s=9"))

    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 17
  end
end

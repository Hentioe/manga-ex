defmodule Manga.Res.VeryDMOriginTest do
  use ExUnit.Case
  import Manga.Res.VeryDMOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  # test "index" do
  #   {state, result} = index(1)
  #   assert state == :ok
  #   assert is_list(result)
  #   assert length(result) == 30
  # end

  # test "stages" do
  #   {state, result} = stages(Info.create(url: "http://www.verydm.com/manhua/huoyingrenzhe"))
  #   send(self(), state)
  #   assert_received :ok, result
  #   assert result.name != nil
  #   assert is_list(result.stage_list)
  #   assert length(result.stage_list) == 457
  # end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "http://www.verydm.com/chapter.php?id=56375"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 22
    IO.inspect(result)
  end
end

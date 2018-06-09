defmodule Manga.Res.GFMHWOriginTest do
  use ExUnit.Case
  import Manga.Res.GFMHWOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 36
  end

  test "stages" do
    {state, result} =
      stages(Info.create(url: "http://www.gufengmh.com/manhua/yinweihuizhangdarenshiweihunfu/"))

    send(self(), state)
    assert_received :ok, result
    assert result.name != nil
    assert is_list(result.stage_list)
    assert length(result.stage_list) == 32
  end

  test "fetch" do
    {state, result} =
      fetch(
        Stage.create(
          url: "http://www.gufengmh.com/manhua/yinweihuizhangdarenshiweihunfu/22862.html"
        )
      )

    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 39
  end
end

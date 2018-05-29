defmodule Manga.Res.FZDMOriginTest do
  use ExUnit.Case
  import Manga.Res.FZDMOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "search" do
    {state, result} = search("进击的巨人")
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "stages" do
    {state, result} = stages(Info.create(url: "https://manhua.fzdm.com/39/"))
    assert state == :ok
    assert is_list(result.stage_list)
    assert length(result.stage_list) > 0
  end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "https://manhua.fzdm.com/2/905/"))
    send(self(), state)
    assert_received :ok, result
    assert length(result.plist) == 16
  end

  test "index" do
    {state, result} = index("")
    assert state == :ok
    assert is_list(result)
    assert length(result) == 152
  end
end

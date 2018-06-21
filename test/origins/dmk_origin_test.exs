defmodule Manga.Res.DMKOriginTest do
  use ExUnit.Case
  import Manga.Res.DMKOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 56
  end

  test "stages" do
    {state, result} = stages(Info.create(url: "http://www.cartoonmad.com/comic/1153.html"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.stage_list)
    assert length(result.stage_list) == 411
  end

  test "fetch" do
    {state, result} =
      fetch(Stage.create(url: "http://www.cartoonmad.com/comic/115301532018001.html"))

    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 18
  end
end

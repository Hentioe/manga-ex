defmodule Manga.Res.DM5OriginTest do
  use ExUnit.Case
  import Manga.Res.DM5Origin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 297
  end

  test "stages" do
    {state, result} = stages(Info.create(url: "http://www.dm5.com/manhua-yaoshenji/"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.stage_list)
    assert length(result.stage_list) == 247
  end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "http://www.dm5.com/m617894/"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 18
  end
end

defmodule Manga.Res.XXMHWOriginTest do
  use ExUnit.Case
  import Manga.Res.XXMHWOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 20
  end

  test "stages" do
    {state, result} = stages(Info.create(url: "https://www.177mh.net/colist_78825.html"))
    send(self(), state)
    assert_received :ok, result
    assert result.name != nil
    assert is_list(result.stage_list)
    assert length(result.stage_list) == 517
  end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "https://www.177mh.net/201611/344894.html"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 30
  end
end

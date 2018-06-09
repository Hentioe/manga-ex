defmodule Manga.Res.MHTOriginTest do
  use ExUnit.Case
  import Manga.Res.MHTOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 36
  end

  test "stages" do
    {state, result} = stages(Info.create(url: "http://www.manhuatai.com/dazhuzai/"))
    send(self(), state)
    assert_received :ok, result
    assert result.name != nil
    assert is_list(result.stage_list)
    assert length(result.stage_list) == 129
  end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "http://www.manhuatai.com/dazhuzai/55wrzbjl.html"))
    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 23
  end
end

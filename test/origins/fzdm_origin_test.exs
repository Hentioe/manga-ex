defmodule Manga.Res.FZDMOriginTest do
  use ExUnit.Case
  import Manga.Res.FZDMOrigin

  test "test search" do
    {state, result} = search("进击的巨人")
    assert state == :error
  end

  test "test stages" do
    {state, result} = stages(%Manga.Res.Info{url: "https://manhua.fzdm.com/39/"})
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "test fetch" do
    {state, result} = fetch(%Manga.Res.Stage{url: "https://manhua.fzdm.com/39/001/"})
    assert state == :ok
    assert is_list(result)
    assert length(result) == 52
  end
end

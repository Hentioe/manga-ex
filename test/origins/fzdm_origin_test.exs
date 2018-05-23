defmodule Manga.Res.FZDMOriginTest do
  use ExUnit.Case
  import Manga.Res.FZDMOrigin

  test "search" do
    {state, result} = search("进击的巨人")
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "stages" do
    {state, result} = stages(%Manga.Res.Info{url: "https://manhua.fzdm.com/39/"})
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  # test "test fetch" do
  #   {state, result} = fetch(%Manga.Res.Stage{url: "https://manhua.fzdm.com/39/001/"})
  #   assert state == :ok
  #   assert is_list(result)
  #   assert length(result) == 52
  # end

  test "index" do
    {state, result} = index("")
    assert state == :ok
    assert is_list(result)
    assert length(result) == 152
  end
end

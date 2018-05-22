defmodule Manga.Res.FZDMOriginTest do
  use ExUnit.Case
  import Manga.Res.FZDMOrigin

  test "test search" do
    {state, result} = search("进击的巨人")
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "test number_list" do
    {state, result} = number_list([{:url, "https://manhua.fzdm.com/39/"}])
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "test fetch" do
    {state, result} = fetch("https://manhua.fzdm.com/39/001/")
    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end

  test "test fetchall" do
    {state, result} =
      Manga.Res.Origin.fetchall(Manga.Res.FZDMOrigin, [{:url, "https://manhua.fzdm.com/39/"}])

    assert state == :ok
    assert is_list(result)
    assert length(result) > 0
  end
end

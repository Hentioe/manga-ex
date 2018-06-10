defmodule Manga.Res.DMZJOriginTest do
  use ExUnit.Case
  import Manga.Res.DMZJOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "index" do
    {state, result} = index()
    send(self(), state)
    assert_received :ok, result
    assert length(result) == 20
  end

  # test "search" do
  #   {state, result} = search("妖精的尾巴")
  #   send(self(), state)
  #   assert_received :ok, result
  #   IO.inspect(result)
  #   assert length(result) == 8
  # end

  test "stages" do
    {state, result} = stages(Info.create(url: "https://manhua.dmzj.com/yiquanchaoren"))
    send(self(), state)
    assert_received :ok, result
    assert length(result.stage_list) == 364
  end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "https://manhua.dmzj.com/yjdwbwzbzgj/31623.shtml"))
    send(self(), state)
    assert_received :ok, result
    assert length(result.plist) == 31
  end
end

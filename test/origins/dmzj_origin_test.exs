defmodule Manga.Res.DMZJOriginTest do
  use ExUnit.Case
  import Manga.Res.DMZJOrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "https://manhua.dmzj.com/yjdwbwzbzgj/31623.shtml"))
    send(self(), state)
    assert_received :ok, result
    assert length(result.plist) == 31
  end
end

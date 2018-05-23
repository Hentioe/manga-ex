defmodule Manga.DLUtilsTest do
  use ExUnit.Case
  import Manga.DLUtils
  import Manga.Res.FZDMOrigin

  test "from_stage" do
    {state, list} = stages(%Manga.Res.Info{url: "https://manhua.fzdm.com/2/"})
    assert state == :ok
    assert is_list(list)
    assert length(list) > 0

    list
    |> List.first()
    |> from_stage(Manga.Res.FZDMOrigin)
  end
end

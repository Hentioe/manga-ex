defmodule Manga.DLUtilsTest do
  use ExUnit.Case
  import Manga.DLUtils
  import Manga.Res.FZDMOrigin
  alias Manga.Model.Info

  test "from_stage" do
    {state, info} = stages(Info.create(url: "https://manhua.fzdm.com/2/"))
    assert state == :ok
    assert length(info.stage_list) > 0

    {state, stage} =
      info.stage_list
      |> List.first()
      |> fetch()

    assert state == :ok
    assert is_list(stage.plist)
    assert length(stage.plist) > 0

    {state, r} = from_stage(stage)

    assert state == :ok
    assert is_list(r)
    assert length(r) > 0
  end
end

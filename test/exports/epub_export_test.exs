defmodule Manga.Res.EpubExportTest do
  use ExUnit.Case
  import Manga.Res.EpubExport
  alias Manga.DLUtils
  alias Manga.Model.Stage
  import Manga.Res.FZDMOrigin

  test "save_from_stage" do
    # 拉取资源
    {state, r} =
      Stage.create(
        name: "灵能百分百101话",
        url: "https://manhua.fzdm.com/49/101/"
      )
      |> fetch

    send(self(), state)
    assert_received :ok, r
    # 下载资源
    DLUtils.from_stage(r)
    # 合并资源
    {state, _} = save_from_stage(r)
    assert state == :ok
  end
end

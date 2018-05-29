defmodule Manga.Res.EpubExportTest do
  use ExUnit.Case
  import Manga.Res.EpubExport
  import Manga.Res.FZDMOrigin
  alias Manga.Model.Stage
  alias Manga.Utils.Downloader

  test "save_from_stage" do
    # 拉取资源
    {state, r} =
      Stage.create(url: "https://manhua.fzdm.com/2/905/")
      |> fetch

    send(self(), state)
    assert_received :ok, r
    # 下载资源
    Downloader.from_stage(r)
    # 合并资源
    {state, _} = save_from_stage(r)
    assert state == :ok
  end
end

defmodule Manga.Utils.DownloaderTest do
  use ExUnit.Case
  import Manga.Utils.Downloader
  import Manga.Res.FZDMOrigin
  alias Manga.Model.Info

  # test "from_stage" do
  #   {state, r} = stages(Info.create(url: "https://manhua.fzdm.com/2/"))
  #   send(self(), state)
  #   assert_received :ok, r
  #   assert length(r.stage_list) > 0

  #   {state, r} =
  #     r.stage_list
  #     |> List.first()
  #     |> fetch()

  #   send(self(), state)
  #   assert_received :ok, r
  #   assert is_list(r.plist)
  #   assert length(r.plist) > 0

  #   {state, r} = from_stage(r)

  #   send(self(), state)
  #   assert_received :ok, r
  #   assert is_list(r)
  #   assert length(r) > 0
  # end

end

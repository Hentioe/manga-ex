defmodule Manga.Res.MHROriginTest do
  use ExUnit.Case
  import Manga.Res.MHROrigin
  alias Manga.Model.Info
  alias Manga.Model.Stage

  # test "index" do
  #   {state, result} = index(1)
  #   assert state == :ok
  #   assert is_list(result)
  #   assert length(result) == 30

  # end

  # test "stages" do
  #   {state, result} =
  #     stages(Info.create(url: "http://www.manhuaren.com/manhua-haizeiwang-onepiece/"))

  #   send(self(), state)
  #   assert_received :ok, result
  #   assert result.name != nil
  #   assert is_list(result.stage_list)
  #   assert length(result.stage_list) == 507
  # end

  test "fetch" do
    {state, result} = fetch(Stage.create(url: "http://www.manhuaren.com/m620540/"))

    assert state == :ok
    assert result.name != nil
    assert is_list(result.plist)
    assert length(result.plist) == 17
  end
end

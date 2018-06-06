defmodule Manga.Utils.DownloaderTest do
  use ExUnit.Case
  import Manga.Utils.Props

  test "get_mac_string" do
    assert get_mac_string() == "3497F68D310"
  end
end

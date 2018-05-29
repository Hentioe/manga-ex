defmodule Manga.Utils.HTTPClientTest do
  use ExUnit.Case

  import Manga.Utils.HTTPClient
  alias Manga.Utils.HTTPClient.Response, as: HPR

  test "test http get" do
    assert get("https://www.fzdm.com/")
           |> HPR.success?()

    assert get("https://www.fzdm.com/")
           |> HPR.body()
           |> Floki.find("title")
           |> Floki.text()
           |> String.equivalent?("风之动漫 - 在线漫画 日本动漫 火影忍者漫画 海贼王漫画")
  end
end

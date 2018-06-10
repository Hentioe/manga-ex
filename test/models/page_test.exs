defmodule Manga.Model.PageTest do
  use ExUnit.Case
  import Manga.Model.Page

  test "set_suffix" do
    url =
      "http://mhpic.mh51.com/comic/D%2F%E6%96%97%E7%A0%B4%E8%8B%8D%E7%A9%B9%E6%8B%86%E5%88%86%E7%89%88%2F1%E8%AF%9D%2F13.jpg-mht.middle.webp.jpg?!2313=123123.1"

      suffix = "jpg"

    assert set_suffix(url) == suffix
  end
end

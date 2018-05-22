defmodule MangaTest do
  use ExUnit.Case
  doctest Manga

  test "greets the world" do
    assert Manga.hello() == :world
  end
end

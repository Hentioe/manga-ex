defmodule Manga.Utils.CheckerTest do
  use ExUnit.Case
  import Manga.Utils.Checker

  test "install_node?" do
    assert install_node?() == true
  end

  test "install_converter?" do
    assert install_converter?() == true
  end
end

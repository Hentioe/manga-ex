defmodule Manga.Utils.IOUtilsTest do
  use ExUnit.Case
  import Manga.Utils.IOUtils

  test "gets_numbers" do
    gets_numbers("1,a,2-9,1-19,27-31")
    |> IO.inspect()
  end
end

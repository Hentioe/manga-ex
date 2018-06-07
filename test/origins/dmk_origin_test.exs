defmodule Manga.Res.DMKOriginTest do
  use ExUnit.Case
  import Manga.Res.DMKOrigin
  # alias Manga.Model.Info
  # alias Manga.Model.Stage

  test "index" do
    {state, result} = index(1)
    assert state == :ok
    assert is_list(result)
    assert length(result) == 56
  end
end

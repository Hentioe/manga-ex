defmodule Manga.Res.Page do
  @default_page :none
  @default_url :none
  defstruct p: @default_page, url: @default_url
end

defmodule Manga.Res.Stage do
  @default_name :none
  @default_url :none
  defstruct name: @default_name, url: @default_url, plist: []
end

defmodule Manga.Res.Info do
  @default_name :none
  @default_url :none
  defstruct name: @default_name, url: @default_url, stage_list: []
end

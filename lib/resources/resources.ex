defmodule Manga.Res.Page do
  @default_page 1
  @default_url "scheme://domain/path"
  defstruct p: @default_page, url: @default_url
end

defmodule Manga.Res.Stage do
  @default_name "第0话"
  @default_url "scheme://domain/path"
  defstruct name: @default_name, url: @default_url, plist: [%Manga.Res.Page{}]
end

defmodule Manga.Res.Info do
  @default_name "Default manga name"
  @default_url "scheme://domain/path"
  defstruct name: @default_name, url: @default_url, number_list: [%Manga.Res.Stage{}]
end

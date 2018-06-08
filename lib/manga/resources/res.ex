defmodule Manga.Res do
  def models do
    quote do
      alias Manga.Model.Platform
      alias Manga.Model.Info
      alias Manga.Model.Stage
      alias Manga.Model.Page
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  alias Manga.Model.Platform

  @platforms [
    dmzj:
      Platform.create(
        name: "动漫之家",
        origin: Manga.Res.DMZJOrigin,
        url: "https://manhua.dmzj.com"
      ),
    fzdm:
      Platform.create(
        name: "风之动漫",
        origin: Manga.Res.FZDMOrigin,
        url: "https://www.fzdm.com"
      ),
    # dmk:
    #   Platform.create(
    #     name: "動漫狂",
    #     origin: Manga.Res.DMKOrigin,
    #     url: "http://www.cartoonmad.com"
    #   ),
    mhg:
      Platform.create(
        name: "漫画柜",
        origin: Manga.Res.MHGOrigin,
        url: "https://www.manhuagui.com"
      ),
    dm5:
      Platform.create(
        name: "动漫屋",
        origin: Manga.Res.DM5Origin,
        url: "http://www.dm5.com"
      ),
    # kkmh:
    # Platform.create(
    #   name: "KuKu动漫",
    #   origin: Manga.Res.KKDMOrigin,
    #   url: "http://comic.kukudm.com"
    # ),
    verydm:
      Platform.create(
        name: "非常爱漫",
        origin: Manga.Res.VeryDMOrigin,
        url: "http://www.verydm.com"
      )
  ]

  @url_mapping [
    [
      pattern: ~r/https?:\/\/manhua\.fzdm\.com\/\d+\/$/i,
      type: {:stages, :fzdm}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.fzdm\.com\/\d+\/[^\/]+\//i,
      type: {:fetch, :fzdm}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.dmzj\.com\/[^\/]+\/?$/i,
      type: {:stages, :dmzj}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.dmzj\.com\/[^\/]+\/\d+\.shtml/i,
      type: {:fetch, :dmzj}
    ],
    [
      pattern: ~r/https?:\/\/www\.dm5\.com\/m\d{6,}[^\/]*\/?$/i,
      type: {:fetch, :dm5}
    ],
    [
      pattern: ~r/https?:\/\/www\.dm5\.com\/[^\/]+\/?$/i,
      type: {:stages, :dm5}
    ],
    [
      pattern: ~r{https?://www\.manhuagui\.com/comic/\d+/?$}i,
      type: {:stages, :mhg}
    ],
    [
      pattern: ~r{https?://www\.manhuagui\.com/comic/\d+/\d+.html$}i,
      type: {:fetch, :mhg}
    ],
    [
      pattern: ~r{https?://www\.verydm\.com/manhua/[^/]+$}i,
      type: {:stages, :verydm}
    ],
    [
      pattern: ~r{https?://www\.verydm\.com/chapter\.php\?id=\d+$}i,
      type: {:fetch, :verydm}
    ]
  ]

  def get_platforms, do: @platforms
  def get_url_mapping, do: @url_mapping
  def get_platform(key), do: @platforms[key]
  def get_origin_by_platform(key), do: get_platform(key).origin
end

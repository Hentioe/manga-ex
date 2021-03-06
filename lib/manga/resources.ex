defmodule Manga.Res do
  @moduledoc false

  def models do
    quote do
      alias Manga.Model.{Platform, Info, Stage, Page}
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
        origin: Manga.Origin.DMZJOrigin,
        url: "https://manhua.dmzj.com"
      ),
    mhg:
      Platform.create(
        name: "漫画柜",
        origin: Manga.Origin.MHGOrigin,
        url: "https://www.manhuagui.com"
      ),
    dm5:
      Platform.create(
        name: "动漫屋",
        origin: Manga.Origin.DM5Origin,
        url: "http://www.dm5.com"
      ),
    mhr:
      Platform.create(
        name: "漫画人",
        origin: Manga.Origin.MHROrigin,
        url: "http://www.manhuaren.com"
      ),
    dmk:
      Platform.create(
        name: "動漫狂",
        origin: Manga.Origin.DMKOrigin,
        url: "http://www.cartoonmad.com"
      ),
    # kkmh:
    # Platform.create(
    #   name: "KuKu动漫",
    #   origin: Manga.Origin.KKDMOrigin,
    #   url: "http://comic.kukudm.com"
    # ),
    verydm:
      Platform.create(
        name: "非常爱漫",
        origin: Manga.Origin.VeryDMOrigin,
        url: "http://www.verydm.com"
      ),
    xxmhw:
      Platform.create(
        name: "新新漫画网",
        origin: Manga.Origin.XXMHWOrigin,
        url: "https://www.177mh.net"
      ),
    mht:
      Platform.create(
        name: "漫画台",
        origin: Manga.Origin.MHTOrigin,
        url: "http://www.manhuatai.com"
      ),
    gfmhw:
      Platform.create(
        name: "古风漫画网",
        origin: Manga.Origin.GFMHWOrigin,
        url: "http://www.gufengmh.com"
      ),
    hhmh:
      Platform.create(
        name: "汗汗漫画",
        origin: Manga.Origin.HHMHOrigin,
        url: "http://www.hhmmoo.com"
      ),
    fzdm:
      Platform.create(
        name: "风之动漫",
        origin: Manga.Origin.FZDMOrigin,
        url: "https://www.fzdm.com"
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
    ],
    [
      pattern: ~r{https?://www\.177mh\.net/colist_\d+\.html$}i,
      type: {:stages, :xxmhw}
    ],
    [
      pattern: ~r{https?://www\.177mh\.net/\d+/\d+.html$}i,
      type: {:fetch, :xxmhw}
    ],
    [
      pattern: ~r{https?://www\.manhuatai\.com/[^/]+/?$}i,
      type: {:stages, :mht}
    ],
    [
      pattern: ~r{https?://www\.manhuatai\.com/.+/.+\.html$}i,
      type: {:fetch, :mht}
    ],
    [
      pattern: ~r{https?://www\.gufengmh\.com/manhua/[^\/]+/?$}i,
      type: {:stages, :gfmhw}
    ],
    [
      pattern: ~r{https?://www\.gufengmh\.com/manhua/[^\/]+/\d+\.html$}i,
      type: {:fetch, :gfmhw}
    ],
    [
      pattern: ~r{https?://www\.hhmmoo\.com/manhua\d+\.html$}i,
      type: {:stages, :hhmh}
    ],
    [
      pattern: ~r{https?://www\.hhmmoo\.com/page\d+/\d+\.html\?}i,
      type: {:fetch, :hhmh}
    ],
    [
      pattern: ~r{https?://www\.manhuaren\.com/manhua-[^\/]+/?$}i,
      type: {:stages, :mhr}
    ],
    [
      pattern: ~r{https?://www\.manhuaren\.com/m\d+/?$}i,
      type: {:fetch, :mhr}
    ],
    [
      pattern: ~r|https?://www\.cartoonmad\.com/comic/\d{15,}\.html|i,
      type: {:fetch, :dmk}
    ],
    [
      pattern: ~r|https?://www\.cartoonmad\.com/comic/\d+\.html|i,
      type: {:stages, :dmk}
    ]
  ]

  def get_platforms, do: @platforms
  def get_url_mapping, do: @url_mapping
  def get_platform(key), do: @platforms[key]
  def get_origin_by_platform(key), do: get_platform(key).origin
end

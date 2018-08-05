defmodule Manga.Origin.FZDMOrigin do
  @moduledoc false

  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  alias Manga.Utils.Props
  import Manga.Utils.ProgressBar
  @url_prefix "http://p0.xiaoshidi.net/"
  @url_regex ~r/mhurl="([^"]+)"/

  def index(_) do
    index()
  end

  def index do
    resp = HC.get("https://manhua.fzdm.com/")

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("ul > div.round > li > a")
        |> Enum.with_index()
        |> Enum.filter(fn {_, i} -> rem(i, 2) != 0 end)
        |> Enum.map(fn {link_node, _} -> link_node end)
        |> Enum.map(fn link_node ->
          Info.create(
            name: link_node |> Floki.attribute("title") |> List.first(),
            url:
              "https://manhua.fzdm.com/" <> (link_node |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:FZDM")}
    end
  end

  def search(words) do
    case index() do
      {:ok, list} ->
        list =
          list
          |> Enum.filter(fn manga -> manga.name |> String.contains?(words) end)

        {:ok, list}

      error ->
        error
    end
  end

  def stages(info) do
    resp = HC.get(info.url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("li.pure-u-1-2.pure-u-lg-1-4 > a")
        |> Enum.map(fn link_node ->
          Stage.create(
            name: Floki.text(link_node),
            url: info.url <> (link_node |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, info |> Info.update_stage_list(list) |> Info.reverse_stage_list()}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  def fetch(stage) do
    render_indeterminate(stage.name, fn -> each_fetch(stage) end)
  end

  def each_fetch(stage, n \\ 0) do
    resp = HC.get(stage.url <> "index_#{n}.html")
    :timer.sleep(Props.get_fetch_delay())

    if HCR.success?(resp) do
      html =
        resp
        |> HCR.body()

      url =
        case Regex.scan(@url_regex, html) do
          [] ->
            nil

          [r] ->
            List.last(r)
        end

      # 设置 stage.name
      stage =
        case stage.name do
          nil ->
            r = Regex.scan(~r/<meta property=\"og:title\" content=\"([^\"]+)\">/i, html)

            r
            |> List.first()
            |> List.last()
            |> (&Stage.rename(stage, &1)).()

          _ ->
            stage
        end

      if url != nil do
        stage = stage |> Stage.add_page(Page.create(p: n + 1, url: @url_prefix <> url))
        each_fetch(stage, n + 1)
      else
        {:ok, stage}
      end
    else
      if HCR.status_code?(resp, 500) do
        {:ok, stage}
      else
        {:error, resp |> HCR.error_msg("Fetch:#{stage.name}")}
      end
    end
  end
end

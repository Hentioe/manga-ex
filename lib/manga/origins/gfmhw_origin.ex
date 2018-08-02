defmodule Manga.Origin.GFMHWOrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar
  import Manga.Utils.JsRuntime

  def index(more \\ 1) do
    url = "http://www.gufengmh.com/list/ribenmanhua/click/#{more}/"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".book-list > li > a")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.attribute("title") |> List.first(),
            url: linkNode |> Floki.attribute("href") |> List.first()
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:GFMHW")}
    end
  end

  def search(_words) do
    {:ok, []}
  end

  def stages(info) do
    resp = HC.get(info.url)

    if HCR.success?(resp) do
      html = resp |> HCR.body()

      list =
        html
        |> Floki.find(~s|.chapter-body > ul > li > a|)
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.text(linkNode),
            url: "http://www.gufengmh.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html
        |> Floki.find(~s|.book-title > h1 > span|)
        |> List.first()
        |> Floki.text()
      end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  @gfmhw_lib_file File.read!("priv/gfmhw_lib.js")
  def fetch(stage) do
    newline()
    render_fetch(stage.name, 0, 2)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = HCR.body(resp)

      script_regex = ~r|<script>;var siteName = "";([\s\S]+)</script><div class="chapter-view">|i

      script =
        Regex.scan(script_regex, html)
        |> List.first()
        |> List.last()
        |> (fn script ->
              ~s|#{script}\n#{@gfmhw_lib_file}|
            end).()

      case eval_to_elixir_result(script) do
        {:ok, [images: images, path: path]} ->
          plist =
            0..(length(images) - 1)
            |> Enum.map(fn i ->
              img = Enum.at(images, i)

              Page.create(
                p: i + 1,
                url: "http://res.gufengmh.com/" <> path <> img
              )
            end)

          render_fetch(stage.name, 1, 2)

          get_name = fn ->
            html
            |> Floki.find(".w996.title.pr")
            |> List.first()
            |> (fn title_node ->
                  (title_node |> Floki.find("h1") |> List.first() |> Floki.text()) <>
                    (title_node |> Floki.find("h2") |> List.first() |> Floki.text())
                end).()
          end

          stage =
            Stage.update_plist(stage, plist)
            |> (fn stage ->
                  if stage.name == nil, do: Stage.rename(stage, get_name.()), else: stage
                end).()

          render_fetch(stage.name, 2, 2)
          {:ok, stage}

        error ->
          error
      end
    else
      {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
    end
  end
end

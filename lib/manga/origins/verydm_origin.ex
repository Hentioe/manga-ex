defmodule Manga.Origin.VeryDMOrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar

  def index(more \\ 1) do
    url =
      "http://www.verydm.com/index.php?r=comic" <>
        "/list&letter=&category_id=&story_id=&tag_id=&status=&" <>
        "show=grid&sort=hits&page=#{more}"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("ul.grid-row.clearfix > li > p > a")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.text(),
            url: linkNode |> Floki.attribute("href") |> List.first()
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:VeryDM")}
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
        |> Floki.find(".chapters > ul.clearfix > li > a")
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.text(linkNode),
            url: "http://www.verydm.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn -> html |> Floki.find(".comic-name > h1") |> Floki.text() end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  def fetch(stage) do
    newline()
    render_fetch(stage.name, 0, 2)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = HCR.body(resp)

      url =
        html
        |> Floki.find(~s{.main[style="display:block"] > img})
        |> List.first()
        |> Floki.attribute("src")
        |> List.first()

      {prefix, suffix} =
        Regex.scan(~r/^(.+)\/\d{3,}.([^\/]+)$/i, url)
        |> List.first()
        |> (fn [_, prefix, suffix] -> {prefix, suffix} end).()

      count =
        html
        |> Floki.find("select > option")
        |> length

      get_img_index = fn i ->
        cond do
          i < 10 -> "00#{i}"
          i >= 10 -> "0#{i}"
          true -> i
        end
      end

      get_name = fn ->
        Floki.find(html, ~s{meta[name="keywords"]})
        |> Floki.attribute("content")
        |> List.first()
        |> String.split("，")
        |> List.first()
      end

      render_fetch(stage.name, 1, 2)

      plist =
        1..count
        |> Enum.map(fn i ->
          Page.create(
            p: i,
            url: "#{prefix}/#{get_img_index.(i)}.#{suffix}",
            http_headers: [
              Referer: stage.url
            ]
          )
        end)

      stage =
        Stage.update_plist(stage, plist)
        |> (fn stage ->
              if stage.name == nil, do: Stage.rename(stage, get_name.()), else: stage
            end).()

      render_fetch(stage.name, 2, 2)
      {:ok, stage}
    else
      {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
    end
  end
end

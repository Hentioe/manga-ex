defmodule Manga.Origin.DMKOrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar

  def index(more \\ 1) do
    page =
      cond do
        more < 10 -> "0#{more}"
        true -> more
      end

    url = "http://www.cartoonmad.com/endcm.#{page}.html"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Mbcs.decode!(:big5)
        |> Floki.find(~s{td[colspan="2"] td[align="center"] > a})
        |> Enum.map(fn aNode ->
          Stage.create(
            name: aNode |> Floki.text(),
            url:
              "http://www.cartoonmad.com/" <> (aNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index: DMK")}
    end
  end

  def search(_words) do
    {:ok, []}
  end

  def stages(info) do
    resp = HC.get(info.url)

    if HCR.success?(resp) do
      html =
        resp
        |> HCR.body()

      list =
        html
        |> Floki.find(~s|fieldset td > a|)
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.text(linkNode) |> Mbcs.decode!(:big5),
            url:
              "http://www.cartoonmad.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html
        |> Floki.find(~s|td[style="font-size:12pt;color:#000066"] > a:last-child|)
        |> Floki.text()
        |> Mbcs.decode!(:big5)
      end

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
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = HCR.body(resp)

      list =
        html
        |> Floki.find(~s|select[name="jump"] > option[value]|)
        |> Enum.map(fn optionNode ->
          optionNode |> Floki.attribute("value") |> List.first()
        end)

      render_fetch(stage.name, 1, length(list))

      get_img = fn html ->
        html
        |> Floki.find(~s|a > img[oncontextmenu='return false']|)
        |> List.first()
        |> Floki.attribute("src")
        |> List.first()
      end

      get_name = fn ->
        html
        |> Floki.find(~s|a[style="font-size:14pt;font-weight: bold;"]|)
        |> Enum.map(fn linkNode ->
          Floki.text(linkNode)
          |> Mbcs.decode!(:big5)
        end)
        |> Enum.join(" - ")
      end

      stage = if stage.name == nil, do: Stage.rename(stage, get_name.()), else: stage

      plist =
        list
        |> Enum.with_index()
        |> Enum.map(fn {value, i} ->
          url =
            if i == 0 do
              get_img.(html)
            else
              case HC.get("http://www.cartoonmad.com/comic/#{value}") do
                resp -> get_img.(resp.body)
                error -> raise "Img fetch failed, #{error}"
              end
            end

          render_fetch(stage.name, i + 1, length(list))

          Page.create(
            p: i + 1,
            url: url
          )
        end)

      stage = Stage.update_plist(stage, plist)

      {:ok, stage}
    else
      {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
    end
  end
end

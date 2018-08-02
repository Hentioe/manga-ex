defmodule Manga.Origin.MHTOrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.{ProgressBar, JsRuntime}

  def index(more \\ 1) do
    url = "http://www.manhuatai.com/all_p#{more}.html"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("a.sdiv[title]")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.attribute("title") |> List.first(),
            url:
              "http://www.manhuatai.com" <> (linkNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:MHT")}
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
        |> Floki.find(~s|ul[name="topiccount"] > li > a|)
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.attribute(linkNode, "title") |> List.first(),
            url: "http://www.manhuatai.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html
        |> Floki.find(~s|meta[property="og:title"]|)
        |> Floki.attribute("content")
        |> List.first()
      end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  @mht_lib_file File.read!("priv/mht_lib.js")
  def fetch(stage) do
    newline()
    render_fetch(stage.name, 0, 2)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = HCR.body(resp)

      script =
        html
        |> (&Regex.scan(~r|var\s*(mh_info\s*=\{[^\}]+\})|i, &1)).()
        |> List.first()
        |> List.last()
        |> (fn script ->
              console_log =
                ~s|console.log(`[count: ${mh_info.totalimg}, path: "${mh_info.imgpath}", start: ${mh_info.startimg}]`)|

              ~s|#{script}\n#{@mht_lib_file}\n#{console_log}|
            end).()

      case eval_to_elixir_result(script) do
        {:ok, [count: count, path: path, start: start]} ->
          plist =
            start..count
            |> Enum.map(fn i ->
              Page.create(
                p: i,
                url: "http://mhpic.mh51.com/comic/" <> path <> "#{i}.jpg-mht.middle.webp"
              )
            end)

          render_fetch(stage.name, 1, 2)

          get_name = fn ->
            html |> Floki.find(".mh_readtitle > h1 > strong") |> List.first() |> Floki.text()
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

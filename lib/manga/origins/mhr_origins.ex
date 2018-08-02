defmodule Manga.Origin.MHROrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar
  import Manga.Utils.JsRuntime

  def index(_more) do
    headers = [
      "User-Agent":
        "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
    ]

    url = "http://www.manhuaren.com/manhua-rank/"

    resp = HC.get(url, headers: headers)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".rankList > #rankList_1 > a")
        |> Enum.map(fn linkNode ->
          Info.create(
            name:
              linkNode
              |> Floki.find(".title.d-nowrap")
              |> List.first()
              |> Floki.text()
              |> String.trim(),
            url:
              "http://www.manhuaren.com" <> (linkNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:MHR")}
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
        |> Floki.find(~s|#chapterList_1 > ul > li > a|)
        |> Enum.map(fn linkNode ->
          Stage.create(
            name:
              Floki.text(linkNode)
              |> String.trim(),
            url: "http://www.manhuaren.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html
        |> Floki.find(~s|.topBar .title.d-nowrap|)
        |> List.first()
        |> Floki.text()
        |> String.trim()
      end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info |> Info.reverse_stage_list()}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  @mhr_lib_file File.read!("priv/mhr_lib.js")
  def fetch(stage) do
    newline()
    render_fetch(stage.name, 0, 2)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = HCR.body(resp)

      script =
        html
        |> (&Regex.scan(
              ~r|(eval\(.+\))[\s\S]*</script>|i,
              &1
            )).()
        |> List.first()
        |> List.last()
        |> (fn script ->
              ~s|#{script}\n#{@mhr_lib_file}|
            end).()

      case eval_to_elixir_result(script) do
        {:ok, img_list} ->
          plist =
            img_list
            |> Enum.map(fn img -> to_string(img) end)
            |> Enum.with_index()
            |> Enum.map(fn {img, i} ->
              Page.create(
                p: i + 1,
                url: img,
                http_headers: [
                  Referer: stage.url
                ]
              )
            end)

          render_fetch(stage.name, 1, 2)

          get_name = fn ->
            html |> Floki.find("#title") |> List.first() |> Floki.text()
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

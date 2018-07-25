defmodule Manga.Res.MHGOrigin do
  use Manga.Res.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  alias Manga.Utils.JsRuntime
  import Manga.Utils.ProgressBar
  import Manga.Utils.Printer

  def index(_more) do
    url = "https://www.manhuagui.com/rank/japan.html"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".rank-detail tr td > h5 > a")
        |> Enum.map(fn aNode ->
          Stage.create(
            name: aNode |> Floki.text(),
            url: "https://www.manhuagui.com" <> (aNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index: DHG")}
    end
  end

  def search(_words) do
    {:ok, []}
  end

  def stages(info) do
    resp =
      HC.get(
        info.url,
        headers: [
          "user-agent": "Mozilla/4.0 (Windows; MSIE 6.0; Windows NT 5.2)"
        ]
      )

    if HCR.success?(resp) do
      html = resp |> HCR.body()

      list =
        html
        |> Floki.find(~s{li > a[class="status0"]})
        |> Enum.map(fn anode ->
          Stage.create(
            name: Floki.attribute(anode, "title") |> List.first(),
            url: "https://www.manhuagui.com" <> (Floki.attribute(anode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html |> Floki.find(".separator + a") |> List.last() |> Floki.text()
      end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info}
    else
      {:error, resp |> HCR.error_msg("Stages: #{info.name}")}
    end
  end

  @mhg_jslib File.read("priv/mhg_lib.js")
  def fetch(stage) do
    newline()
    render_fetch("???", 0, 1)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      script =
        resp
        |> HCR.body()
        |> (&Regex.scan(~r/window\["\\x65\\x76\\x61\\x6c"\]\((.+)\)\s+\<\/script\>/i, &1)).()
        |> List.first()
        |> List.last()
        |> (fn script ->
              {:ok, script_lib} = @mhg_jslib
              "#{script_lib}\neval(#{script})"
            end).()

      case JsRuntime.eval_to_elixir_result(script) do
        {:ok, result} ->
          plist =
            result[:files]
            |> Enum.map(fn name ->
              "https://us.hamreus.com/#{URI.encode(result[:path])}#{name}?cid=#{result[:cid]}&md5=#{
                result[:md5]
              }"
            end)
            |> Enum.with_index()
            |> Enum.map(fn {url, i} ->
              Page.create(
                p: i + 1,
                url: url,
                http_headers: [Referer: stage.url]
              )
            end)

          stage =
            Stage.update_plist(stage, plist)
            |> (fn stage ->
                  if stage.name == nil, do: Stage.rename(stage, result[:name]), else: stage
                end).()

          render_fetch(stage.name, 1, 1)
          {:ok, stage}

        error ->
          error
      end
    else
      {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
    end
  end
end

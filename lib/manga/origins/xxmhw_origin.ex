defmodule Manga.Origin.XXMHWOrigin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar
  import Manga.Utils.JsRuntime

  def index(more \\ 1) do
    url = "https://www.177mh.net/wanjie/index_#{more - 1}.html"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".ar_list_co > ul > li > span > a")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.text(),
            url: "https://www.177mh.net" <> (linkNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:XXMHW")}
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
        |> Floki.find("ul.ar_rlos_bor.ar_list_col > li > a")
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.text(linkNode),
            url: "https://www.177mh.net" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn -> html |> Floki.find("ul.ar_list_coc > li > h1") |> Floki.text() end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info |> Info.reverse_stage_list()}
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

      script =
        html
        |> (&Regex.scan(~r{<script type="text/javascript">[\s\n]+(eval.+)[\s\n]+</script>}i, &1)).()
        |> List.first()
        |> List.last()
        |> (fn script -> ~s|#{script}\nconsole.log(`[msg: "${msg}", img_s: "${img_s}"]`)| end).()

      case eval_to_elixir_result(script) do
        {:ok, [msg: msg, img_s: img_s]} ->
          plist =
            msg
            |> String.split("|")
            |> Enum.with_index()
            |> Enum.map(fn {path, i} ->
              Page.create(
                p: i + 1,
                url: "https://hws.readingbox.net/h#{img_s}/" <> path,
                http_headers: [
                  Referer: stage.url
                ]
              )
            end)

          render_fetch(stage.name, 1, 2)

          get_name = fn ->
            html |> Floki.find("#tab_srv + h1 > a") |> List.first() |> Floki.text()
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

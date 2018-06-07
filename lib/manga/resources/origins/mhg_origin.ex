defmodule Manga.Res.MHGOrigin do
  @behaviour Manga.Res.Origin
  alias Manga.Model.Info
  alias Manga.Model.Stage
  alias Manga.Model.Page
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar

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
            name: Floki.text(anode),
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

  def fetch(stage) do
    {:ok, stage}
  end
end

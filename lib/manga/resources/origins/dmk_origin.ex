defmodule Manga.Res.DMKOrigin do
  @behaviour Manga.Res.Origin
  alias Manga.Model.Info
  alias Manga.Model.Stage
  alias Manga.Model.Page
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.Printer
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
    {:ok, info}
  end

  def fetch(stage) do
    {:ok, stage}
  end
end

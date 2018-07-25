defmodule Manga.Res.KKDMOrigin do
  use Manga.Res.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR

  def index(more \\ 1) do
    url = "http://comic.kukudm.com/comictype/3_#{more}.htm"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("#comicmain > dd > a:nth-child(2)")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.text(),
            url: linkNode |> Floki.attribute("href") |> List.first()
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:KKDM")}
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

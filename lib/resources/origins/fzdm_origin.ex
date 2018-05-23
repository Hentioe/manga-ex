defmodule Manga.Res.FZDMOrigin do
  @behaviour Manga.Res.Origin
  alias Manga.Res.Info
  alias Manga.Res.Stage
  alias Manga.Res.Page
  alias Manga.HTTPClient, as: HC
  alias Manga.HTTPClient.Response, as: HCR
  @url_prefix "http://p0.xiaoshidi.net/"
  @url_regex ~r/mhurl="([^"]+)"/

  def search(_words) do
    {:error, "Not implemented"}
  end

  def stages(info) do
    list =
      info.url
      |> HC.get()
      |> HCR.body()
      |> Floki.find("li > a")
      |> Enum.map(fn linkNode ->
        %Stage{
          name: Floki.text(linkNode),
          url: info.url <> (linkNode |> Floki.attribute("href") |> List.first())
        }
      end)

    {:ok, list}
  end

  def fetch(stage, list \\ [], n \\ 0) do
    resp = HC.get(stage.url <> "index_#{n}.html")

    if HCR.success?(resp) do
      html =
        resp
        |> HCR.body()

      url =
        Regex.scan(@url_regex, html)
        |> List.first()
        |> List.last()

      fetch(stage, list ++ [%Page{p: n + 1, url: @url_prefix <> url}], n + 1)
    else
      if(HCR.status_code?(resp, 500)) do
        {:ok, list}
      else
        {:error, "Fetch #{stage.name} failed"}
      end
    end
  end
end

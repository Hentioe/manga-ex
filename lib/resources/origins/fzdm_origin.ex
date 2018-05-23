defmodule Manga.Res.FZDMOrigin do
  @behaviour Manga.Res.Origin
  alias Manga.Res.Info
  alias Manga.Res.Stage
  alias Manga.Res.Page
  alias Manga.HTTPClient, as: HC
  alias Manga.HTTPClient.Response, as: HCR
  @url_prefix "http://p0.xiaoshidi.net/"
  @url_regex ~r/mhurl="([^"]+)"/

  def index(_) do
    index()
  end

  def index do
    resp = HC.get("https://manhua.fzdm.com/")

    if(HCR.success?(resp)) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("ul > div.round > li > a")
        |> Enum.with_index()
        |> Enum.filter(fn {_, i} -> rem(i, 2) != 0 end)
        |> Enum.map(fn {linkNode, _} -> linkNode end)
        |> Enum.map(fn linkNode ->
          %Info{
            name: linkNode |> Floki.attribute("title") |> List.first(),
            url:
              "https://manhua.fzdm.com/" <> (linkNode |> Floki.attribute("href") |> List.first())
          }
        end)

      {:ok, list}
    else
      {:error, "Get index falied"}
    end
  end

  def search(words) do
    case index() do
      {:ok, list} ->
        list =
          list
          |> Enum.filter(fn manga -> manga.name |> String.contains?(words) end)

        {:ok, list}

      {:error, error} ->
        {:error, error}
    end
  end

  def stages(info) do
    list =
      info.url
      |> HC.get()
      |> HCR.body()
      |> Floki.find("li.pure-u-1-2.pure-u-lg-1-4 > a")
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

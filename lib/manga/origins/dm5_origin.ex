defmodule Manga.Origin.DM5Origin do
  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar

  def index(_more \\ 1) do
    url = "http://www.dm5.com/manhua-rank/?t=2"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find("ul.mh-list.col3.top-cat > li .mh-item-detali > h2.title > a")
        |> Enum.map(fn aNode ->
          Stage.create(
            name: aNode |> Floki.text(),
            url: "http://www.dm5.com" <> (aNode |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index: DM5")}
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
        |> Floki.find("ul > li > a[title]")
        |> Enum.map(fn linkNode ->
          Stage.create(
            name:
              Floki.raw_html(linkNode)
              |> (&Regex.scan(~r|\>(.+)\<span\>|, &1)).()
              |> List.first()
              |> List.last()
              |> String.trim(),
            url: "http://www.dm5.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn ->
        Regex.scan(~r/DM5_COMIC_MNAME="([^"]+)"/i, html) |> List.first() |> List.last()
      end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info |> Info.reverse_stage_list()}
    else
      {:error, resp |> HCR.error_msg("Stages: #{info.name}")}
    end
  end

  def fetch(stage) do
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      html = resp |> HCR.body()

      name =
        html
        |> (&Regex.scan(~r/var\s*DM5_CTITLE\s*=\s*"([^"]+)";/i, &1)).()
        |> List.first()
        |> List.last()

      mid =
        html
        |> (&Regex.scan(~r/var\s*DM5_MID\s*=\s*([^;]+);/i, &1)).()
        |> List.first()
        |> List.last()

      cid =
        html
        |> (&Regex.scan(~r/var\s*DM5_CID\s*=\s*([^;]+);/i, &1)).()
        |> List.first()
        |> List.last()

      count =
        html
        |> (&Regex.scan(~r/var\s*DM5_IMAGE_COUNT\s*=\s*([^;]+);/i, &1)).()
        |> List.first()
        |> List.last()
        |> Integer.parse()
        |> (fn {n, _} -> n end).()

      sign =
        html
        |> (&Regex.scan(~r/var\s*DM5_VIEWSIGN\s*=\s*"([^"]+)";/i, &1)).()
        |> List.first()
        |> List.last()

      dt =
        html
        |> (&Regex.scan(~r/var\s*DM5_VIEWSIGN_DT\s*=\s*"([^"]+)";/i, &1)).()
        |> List.first()
        |> List.last()

      url_params = "&cid=#{cid}&_cid=#{cid}&_mid=#{mid}&_dt=#{URI.encode(dt)}&_sign=#{sign}"

      render_fetch(name, 1, count)

      plist =
        each_fetch(url_params, count, stage.url, name)
        |> Enum.with_index()
        |> Enum.map(fn {url, i} ->
          Page.create(
            p: i + 1,
            url: to_string(url),
            http_headers: [
              Referer: stage.url
            ]
          )
        end)

      stage =
        Stage.update_plist(stage, plist)
        |> (fn stage ->
              if stage.name == nil, do: Stage.rename(stage, name), else: stage
            end).()

      render_fetch(name, count, count)
      {:ok, stage}
    else
      {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
    end
  end

  defp each_fetch(url_params, count, referer, name, list \\ [], page \\ 1) do
    if(page <= count) do
      url =
        "http://www.dm5.com/m617894/chapterfun.ashx?page=#{page}&&key=&language=1&gtk=6#{
          url_params
        }"

      resp =
        HC.get(
          url,
          headers: [
            Referer: referer
          ]
        )

      if HCR.success?(resp) do
        clist =
          resp.body
          |> (fn eval ->
                eval <> "console.log(d)"
              end).()
          |> (&System.cmd("node", ["-e", &1])).()
          |> (fn {output, _} ->
                output
                |> Code.eval_string()
                |> (fn {data, _} -> data end).()
              end).()

        if count != page, do: render_fetch(name, page, count)
        each_fetch(url_params, count, referer, name, list ++ clist, page + length(clist))
      end
    else
      list
    end
  end
end

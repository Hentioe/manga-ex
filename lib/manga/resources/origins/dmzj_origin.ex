defmodule Manga.Res.DMZJOrigin do
  @behaviour Manga.Res.Origin
  alias Manga.Model.Info
  alias Manga.Model.Stage
  alias Manga.Model.Page
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar
  def index(props \\ nil) do
    {url, _page} =
      case props do
        nil -> {"https://manhua.dmzj.com/rank/", 1}
      end

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".middlerighter span.title > a")
        |> Enum.map(fn linkNode ->
          Info.create(
            name: linkNode |> Floki.text(),
            url: linkNode |> Floki.attribute("href") |> List.first()
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:DMZJ")}
    end
  end

  def search(_words) do
    {:ok, []}
    # url = "https://manhua.dmzj.com/tags/search.shtml?s=#{URI.encode(words)}"
    # resp = HC.get(url)

    # if HCR.success?(resp) do
    #   list =
    #     resp
    #     |> HCR.body()
    #     |> IO.puts()
    #     |> Floki.find(".tcaricature_new .tcaricature_block.tcaricature_block2 > ul > li > a")
    #     |> Enum.map(fn linkNode ->
    #       Info.create(
    #         name: linkNode |> Floki.text(),
    #         url: "https:" <> (linkNode |> Floki.attribute("href") |> List.first())
    #       )
    #     end)

    #   {:ok, list}
    # else
    #   {:error, resp |> HCR.error_msg("Search:DMZJ")}
    # end
  end

  def stages(info) do
    resp = HC.get(info.url)

    if HCR.success?(resp) do
      html = resp |> HCR.body()

      list =
        html
        |> Floki.find(".cartoon_online_border > ul > li > a")
        |> Enum.map(fn linkNode ->
          Stage.create(
            name: Floki.text(linkNode),
            url: "https://manhua.dmzj.com" <> (Floki.attribute(linkNode, "href") |> List.first())
          )
        end)

      get_name = fn -> html |> Floki.find(".anim_title_text > a > h1") |> Floki.text() end

      info =
        Info.update_stage_list(info, list)
        |> (fn info -> if info.name == nil, do: Info.rename(info, get_name.()), else: info end).()

      {:ok, info}
    else
      {:error, resp |> HCR.error_msg("Stages:#{info.name}")}
    end
  end

  @page_http_headers %{
    "user-agent" =>
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.62 Safari/537.36",
    "referer" => "https://manhua.dmzj.com"
  }
  @page_http_options [ssl: [{:versions, [:"tlsv1.2"]}]]

  def fetch(stage) do
    render_fetch("???", 0, 1)
    resp = HC.get(stage.url)

    if HCR.success?(resp) do
      result =
        resp
        |> HCR.body()
        |> (&Regex.scan(~r/<script type="text\/javascript">([\s\S]+)var res_type/i, &1)).()
        |> List.first()
        |> List.last()
        |> (fn script ->
              script <>
                "console.log(`[pages: ${pages}, name: \"${g_comic_name}${g_chapter_name}\"]`)"
            end).()
        |> (&System.cmd("node", ["-e", &1])).()

      case result do
        {code, 0} ->
          data =
            code
            |> Code.eval_string()
            |> (fn {data, _} -> data end).()

          plist =
            data[:pages]
            |> Enum.with_index()
            |> Enum.map(fn {path, i} ->
              Page.create(
                p: i + 1,
                url: "https://images.dmzj.com/" <> path,
                http_headers: @page_http_headers,
                http_options: @page_http_options
              )
            end)

          stage =
            Stage.update_plist(stage, plist)
            |> (fn stage ->
                  if stage.name == nil, do: Stage.rename(stage, data[:name]), else: stage
                end).()

          render_fetch(stage.name, 1, 1)
          {:ok, stage}

        error ->
          {:error, "Fetch:#{stage.name} Node.js -e error: #{error}"}
      end
    else
      {:error, resp |> HCR.error_msg("Fetch:#{stage.name}")}
    end
  end
end

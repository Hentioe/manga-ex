defmodule Manga.Origin.HHMHOrigin do

  @moduledoc false

  use Manga.Origin
  use Manga.Res, :models
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR
  import Manga.Utils.ProgressBar
  import Manga.Utils.JsRuntime

  def index(_more) do
    url = "http://www.hhmmoo.com/top/hotrating.aspx"

    resp = HC.get(url)

    if HCR.success?(resp) do
      list =
        resp
        |> HCR.body()
        |> Floki.find(".cTopComicList > .cComicItem > a")
        |> Enum.map(fn link_node ->
          Info.create(
            name: link_node |> Floki.text(),
            url: "http://www.hhmmoo.com" <> (link_node |> Floki.attribute("href") |> List.first())
          )
        end)

      {:ok, list}
    else
      {:error, resp |> HCR.error_msg("Index:HHMH")}
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
        |> Floki.find(~s|.cVolUl > li > a|)
        |> Enum.map(fn link_node ->
          Stage.create(
            name: Floki.text(link_node),
            url: "http://www.hhmmoo.com" <> (Floki.attribute(link_node, "href") |> List.first())
          )
        end)

      get_name = fn ->
        html
        |> Floki.find(~s|#about_kit h1|)
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

  def fetch(stage) do
    newline()

    {prefix, suffix} =
      Regex.scan(~r{^([^\?]+)/\d*.html(.+)$}, stage.url)
      |> List.first()
      |> (fn [_, prefix, suffix] -> {prefix, suffix} end).()

    each_fetch(stage, prefix, suffix)
  end

  @hhmh_lib_file File.read!("priv/hhmh_lib.js")
  defp each_fetch(stage, prefix_path, suffix, n \\ 1, count \\ -1) do
    if n - 1 == count do
      {:ok, stage}
    else
      resp = HC.get("#{prefix_path}/#{n}.html#{suffix}")

      if HCR.success?(resp) do
        html = HCR.body(resp)

        img_name_attr =
          html
          |> Floki.find("#iBodyQ img")
          |> List.first()
          |> Floki.attribute("name")
          |> List.first()

        hostname =
          Regex.scan(~r{^(https?://[^/]+)/}, stage.url)
          |> List.first()
          |> List.last()

        prefix =
          html
          |> Floki.find("#hdDomain")
          |> List.first()
          |> Floki.attribute("value")
          |> List.first()
          |> String.split("|")
          |> List.first()

        get_count = fn ->
          html
          |> Floki.find("#iPageHtm > a")
          |> length
        end

        script =
          ~s|var hostname="#{hostname}";var imgNameAttr="#{img_name_attr}"\n| <> @hhmh_lib_file

        case eval_to_elixir_result(script) do
          {:ok, path} ->
            page = Page.create(p: n, url: prefix <> path)

            get_name = fn ->
              html
              |> Floki.find("title")
              |> List.first()
              |> Floki.text()
              |> String.split("-")
              |> List.first()
              |> String.trim()
            end

            stage =
              Stage.add_page(stage, page)
              |> (fn stage ->
                    if stage.name == nil, do: Stage.rename(stage, get_name.()), else: stage
                  end).()

            count = if count == -1, do: get_count.(), else: count
            render_fetch(stage.name, n, count)
            each_fetch(stage, prefix_path, suffix, n + 1, count)

          error ->
            error
        end
      else
        {:error, resp |> HCR.error_msg("Fetch:[#{stage.name}]")}
      end
    end
  end
end

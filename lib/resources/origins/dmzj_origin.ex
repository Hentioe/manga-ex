defmodule Manga.Res.DMZJOrigin do
  @behaviour Manga.Res.Origin
  import Manga.Utils.Printer
  alias Manga.Model.Info
  alias Manga.Model.Stage
  alias Manga.Model.Page
  alias Manga.Utils.HTTPClient, as: HC
  alias Manga.Utils.HTTPClient.Response, as: HCR

  def fetch(stage) do
    resp = HC.get(stage.url)
    print_info("[Fetching] #{stage.url}")

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
              Page.create(p: i + 1, url: "https://images.dmzj.com/" <> path)
            end)

          stage =
            Stage.update_plist(stage, plist)
            |> (fn stage ->
                  if stage.name == nil, do: Stage.rename(stage, data[:name]), else: stage
                end).()

          {:ok, stage}

        error ->
          {:error, "Fetch:#{stage.name} Node.js -e error: #{error}"}
      end
    else
      {:error, resp |> HCR.error_msg("Fetch:#{stage.name}")}
    end
  end
end

defmodule Manga do
  import Manga.Utils.Printer
  import Manga.Utils.ProgressBar
  alias Manga.Utils.Props

  @moduledoc """
  Documentation for Manga.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Manga.hello
      :world

  """
  def hello do
    :world
  end

  use Manga.Res, :models
  alias Manga.Utils.IOUtils

  @version "alpha7-3"

  @platforms [
    dmzj:
      Platform.create(
        name: "动漫之家",
        origin: Manga.Res.DMZJOrigin
      ),
    fzdm:
      Platform.create(
        name: "风之动漫",
        origin: Manga.Res.FZDMOrigin
      )
  ]

  def main(args \\ []) do
    switches = [
      version: :boolean,
      help: :boolean,
      delay: :lists
    ]

    aliases = [
      v: :version,
      h: :help,
      d: :delay
    ]

    parsed = OptionParser.parse(args, switches: switches, aliases: aliases)
    # IO.inspect(parsed)

    case parsed do
      {_, ["cleancache"], _} ->
        File.rm_rf("./_res/.cache")

      {[version: true], _, _} ->
        print_normal("Erlang/OPT #{:erlang.system_info(:otp_release)} [#{get_system_info()}]")
        print_normal("Manga.ex #{@version}")

      {props, argv, _} ->
        Props.set_delay(props[:delay])

        if length(argv) > 0 do
          url =
            argv
            |> List.first()

          action(:intellig, url: url)
        else
          action(:default)
        end
    end
  end

  def action(:default) do
    # 交互模式
    print_normal("Welcome to Manga.ex! Currently supported platform list:\n")

    list =
      @platforms
      |> Enum.map(fn {_, platform} -> platform end)
      |> Enum.with_index()
      |> Enum.map(fn {platform, i} ->
        print_result("[#{i + 1}]: #{platform.name}")
        platform
      end)

    {n, _} =
      IOUtils.gets("\nPlease select a platform, [Number]: ")
      |> String.trim()
      |> Integer.parse()

    Enum.at(list, n - 1) |> index
  end

  def action(:intellig, url: url) do
    export(url)
  end

  defp index(p) do
    case p.origin.index() do
      {:ok, list} ->
        newline()

        list
        |> Enum.with_index()
        |> Enum.each(fn {manga_info, i} ->
          print_result("[#{i + 1}]: #{manga_info.name}")
        end)

        {n, _} = IOUtils.gets_number("\nPlease select a manga, [Number]: ")
        Enum.at(list, n - 1).url |> export()

      {:error, error} ->
        print_error(error)
    end
  end

  defp export(url) do
    case platform?(url) do
      # 待选择的(话/卷)列表
      {:stages, key} ->
        newline()

        case @platforms[key].origin.stages(Info.create(url: url)) do
          {:ok, manga_info} ->
            list =
              manga_info.stage_list
              |> Enum.with_index()
              |> Enum.map(fn {stage, i} ->
                print_result("[#{i + 1}]: #{stage.name}")
                stage
              end)

            {n, _} = IOUtils.gets_number("\nPlease select a stage, [Number]: ")

            Enum.at(list, n - 1).url |> export()

          {:error, error} ->
            print_error(error)
        end

      # 获取漫画内容（下载并保存）
      {:fetch, key} ->
        with {:ok, stage} <- @platforms[key].origin.fetch(Stage.create(url: url)),
             {:ok, _} <- Manga.Utils.Downloader.from_stage(stage),
             {:ok, _} <-
               (fn ->
                  render_export(stage.name, 1, 2)
                  r = Manga.Res.EpubExport.save_from_stage(stage)
                  render_export(stage.name, 2, 2)
                  newline()
                  r
                end).() do
          # 输出结果
        else
          {:error, error} ->
            print_error(error)
        end

      {:error, error} ->
        print_error(error)
    end
  end

  @url_mapping [
    [
      pattern: ~r/https?:\/\/manhua\.fzdm\.com\/\d+\/$/i,
      type: {:stages, :fzdm}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.fzdm\.com\/\d+\/[^\/]+\//i,
      type: {:fetch, :fzdm}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.dmzj\.com\/[^\/]+\/?$/i,
      type: {:stages, :dmzj}
    ],
    [
      pattern: ~r/https?:\/\/manhua\.dmzj\.com\/[^\/]+\/\d+\.shtml/i,
      type: {:fetch, :dmzj}
    ]
  ]

  defp platform?(url) do
    is_match = fn pattern -> Regex.match?(pattern, url) end

    @url_mapping
    |> Enum.filter(fn mapping ->
      is_match.(mapping[:pattern])
    end)
    |> List.first()
    |> (fn mapping ->
          if mapping == nil, do: {:error, "Unknown platform url"}, else: mapping[:type]
        end).()
  end

  defp get_system_info do
    {family, name} = :os.type()
    "#{Atom.to_string(family)}/#{Atom.to_string(name)}"
  end

  def start(_type, _args) do
    Props.start_link(%{})
  end
end

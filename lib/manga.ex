defmodule Manga do
  import Manga.Res
  alias Manga.Utils.{Printer, ProgressBar, Props, Checker, IOUtils}
  use Tabula
  use Manga.Res, :models
  @version "alpha9-15"

  def main(args \\ []) do
    case passed() do
      {:error, msg} ->
        Printer.print_error(msg)
        System.halt(1)

      {:warning, msg} ->
        Printer.print_warning(msg)

      _ ->
        nil
    end

    switches = [
      version: :boolean,
      help: :boolean,
      delay: :string
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
        print_version()

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
    Printer.print_normal("Welcome to Manga.ex! Currently supported platform list:\n")

    list =
      get_platforms()
      |> Enum.map(fn {_, platform} -> platform end)
      |> Enum.with_index()
      |> Enum.map(
           fn {platform, i} ->
             Printer.print_result(
               "[#{i + 1}]: #{platform.name}#{
                 if platform.flags == nil, do: "", else: "(#{platform.flags})"
               }"
             )

             platform
           end
         )

    {n, _} =
      IOUtils.gets("\nPlease select a platform, [Number]: ")
      |> String.trim()
      |> Integer.parse()

    origin = Enum.at(list, n - 1)
    Props.init_more(origin)
    index(origin)
  end

  def action(:intellig, url: url) do
    export(url)
  end

  defp index(p) do
    case p.origin.index(Props.get_and_more()) do
      {:ok, list} ->
        Printer.newline()

        list
        |> Enum.with_index()
        |> Enum.each(
             fn {manga_info, i} ->
               Printer.print_result("[#{i + 1}]: #{manga_info.name}")
             end
           )

        case IOUtils.gets_number("\n[Number -> select a manga] or [Anything -> next page]: ") do
          {n, _} ->
            Enum.at(list, n - 1).url
            |> export()
          :error ->
            index(p)
        end

      {:error, error} ->
        Printer.print_error(error)
    end
  end

  defp export(url) do
    case platform?(url) do
      # 待选择的(话/卷)列表
      {:stages, key} ->
        Printer.newline()

        case get_platform(key).origin.stages(Info.create(url: url)) do
          {:ok, manga_info} ->
            list =
              manga_info.stage_list
              |> Enum.with_index()
              |> Enum.map(
                   fn {stage, i} ->
                     Printer.print_result("[#{i + 1}]: #{stage.name}")
                     stage
                   end
                 )

            IOUtils.gets_numbers("\nPlease select a stage, [n/n1,n2/n1-n5,n7]: ")
            |> Enum.each(
                 fn n ->
                   Enum.at(list, n - 1).url
                   |> export() end
               )

          {:error, error} ->
            Printer.print_error(error)
        end

      # 获取漫画内容（下载并保存）
      {:fetch, key} ->
        with {:ok, stage} <- get_origin_by_platform(key).fetch(Stage.create(url: url)),
             {:ok, _} <- Manga.Utils.Downloader.from_stage(stage),
             rlist <-
               (fn ->
                 stage = Stage.set_platform(stage, get_platform(key))
                 converter_list = get_converter_list()
                 render_length = length(converter_list)
                 ProgressBar.render_export(stage.name, 0, render_length)

                 converter_list
                 |> Enum.with_index()
                 |> Enum.map(
                      fn {{format, converter}, i} ->
                        r = converter.save_from_stage(stage)
                        ProgressBar.render_export(stage.name, i + 1, render_length)
                        {format, r}
                      end
                    )
                end).() do
          Printer.newline()
          # 输出结果

          rlist
          |> Enum.map(
               fn r ->
                 case r do
                   {format, {:ok, path}} ->
                     %{"FORMAT" => format, "INFO" => path, "RESULT" => "✔"}

                   {format, {:error, error}} ->
                     %{"FORMAT" => format, "INFO" => error, "RESULT" => "✘"}
                 end
               end
             )
          |> print_table
        else
          {:error, error} ->
            Printer.print_error(error)
        end

      {:error, error} ->
        Printer.print_error(error)
    end
  end

  defp platform?(url) do
    is_match = fn pattern -> Regex.match?(pattern, url) end

    get_url_mapping()
    |> Enum.filter(
         fn mapping ->
           is_match.(mapping[:pattern])
         end
       )
    |> List.first()
    |> (fn mapping ->
      if mapping == nil, do: {:error, "Unknown platform url"}, else: mapping[:type]
        end).()
  end

  defp get_system_info do
    {family, name} = :os.type()
    "#{Atom.to_string(family)}/#{Atom.to_string(name)}"
  end

  defp get_converter_list do
    converts = [{"EPUB", Manga.Res.EpubExport}]

    if Checker.install_converter?(),
       do: converts ++ [{"MOBI", Manga.Res.MobiExport}, {"PDF", Manga.Res.PdfExport}],
       else: converts
  end

  defp passed do
    Props.init_table()

    cond do
      !Checker.install_node?() ->
        {:error, "Please install Node.js: https://nodejs.org"}

      !Checker.install_converter?() ->
        {:warning, "Missing conversion tools will limit the output format!"}

      true ->
        {:ok}
    end
  end

  def version, do: @version

  defp print_version do
    get_printer().echo_normal("Erlang/OPT #{:erlang.system_info(:otp_release)} [#{get_system_info()}]")
    get_printer().echo_normal("Manga.ex #{@version} (compiled with Elixir #{System.version()})")
  end

  defp get_printer do
    Manga.Printer.get_current_printer()
  end

end

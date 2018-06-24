defmodule Mix.Tasks.Bundle do
  use Mix.Task

  def run(_args) do
    case System.cmd("mix", ["escript.build"]) do
      {output, 0} ->
        IO.puts(output)
        File.cp!("manga", "scripts/manga")
        File.rm!("manga")

        archive_name = "./scripts/manga_#{Manga.version()}"
        files = ["manga", "manga.ps1", "manga.bat"]

        :zip.create(
          archive_name <> ".zip",
          files |> Enum.map(fn f -> to_charlist(f) end),
          cwd: "./scripts"
        )
        |> IO.inspect()

        :erl_tar.create(
          archive_name <> ".tar.gz",
          files |> Enum.map(fn f -> "#{Path.absname("")}/scripts/#{f}" |> to_charlist() end)
        )
        |> (fn r -> if r == :ok, do: {:ok, archive_name <> ".tar.gz"}, else: r end).()
        |> IO.inspect()

      {output, error_code} ->
        IO.puts("Bundle failed, info [#{error_code}]: #{output}")
    end
  end
end

defmodule Mix.Tasks.Bundle do
  use Mix.Task

  def run(_args) do
    case System.cmd("mix", ["escript.build"]) do
      {output, 0} ->
        IO.puts(output)
        File.cp!("manga", "scripts/manga")
        File.rm!("manga")

        :zip.create(
          "./scripts/manga_#{Manga.version()}.zip",
          ['manga', 'manga.ps1', 'manga.bat'],
          cwd: "./scripts"
        )
        |> IO.inspect()

      {output, error_code} ->
        IO.puts("Bundle failed, info [#{error_code}]: #{output}")
    end
  end
end

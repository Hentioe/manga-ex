defmodule Mix.Tasks.Manga.Bundle do
  @moduledoc false

  use Mix.Task

  def run(_args) do
    case System.cmd("mix", ["escript.build"]) do
      {output, 0} ->
        IO.puts(output)
        File.cp!("manga", "dist/manga")
        File.rm!("manga")

        archive_name = "./dist/manga_#{Manga.version()}"
        files = ["manga", "manga.ps1", "manga.bat"]

        zip_r =
          :zip.create(
            archive_name <> ".zip",
            files |> Enum.map(fn f -> to_charlist(f) end),
            cwd: "./dist"
          )

        tar_r =
          :erl_tar.create(
            archive_name <> ".tar.gz",
            files |> Enum.map(fn f -> "#{Path.absname("")}/dist/#{f}" |> to_charlist() end)
          )
          |> (fn r -> if r == :ok, do: {:ok, archive_name <> ".tar.gz"}, else: r end).()

        echo_result = fn r, f ->
          case r do
            {:ok, path} -> IO.puts("Bundled #{f} ok, #{path}")
            {:error, error} -> IO.puts("Bundle #{f} error: #{error}")
          end
        end

        echo_result.(zip_r, "zip")
        echo_result.(tar_r, "tar.gz")

      {output, error_code} ->
        IO.puts("Bundle failed, info [#{error_code}]: #{output}")
    end
  end
end

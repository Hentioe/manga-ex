defmodule Manga.Utils.Checker do
  def install_node? do
    case cmd("node", ["-v"]) do
      {:ok, _} ->
        true

      _ ->
        false
    end
  end

  def install_converter? do
    case cmd("ebook-convert", ["--version"]) do
      {:ok, _} ->
        true

      _ ->
        false
    end
  end

  defp cmd(cmd, args) do
    try do
      case System.cmd(cmd, args) do
        {output, 0} -> {:ok, output}
        {output, code} -> {:error, "Exited! output: #{output}, code: #{code}"}
      end
    rescue
      e in ErlangError -> {:error, e}
    end
  end
end

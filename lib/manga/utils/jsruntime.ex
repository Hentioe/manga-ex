defmodule Manga.Utils.JsRuntime do

  @moduledoc false

  defp eval_from_node(script_code) do
    case System.cmd("node", ["-e", script_code]) do
      {output, 0} ->
        {:ok, output}

      {output, error_code} ->
        {:error, "Node.js:[#{error_code}] #{output} "}
    end
  end

  defp eval_to_elixir(script_code) do
    case eval_from_node(script_code) do
      {:ok, output} ->
        {:ok, Code.eval_string(output)}

      error ->
        error
    end
  end

  def eval_to_elixir_result(script_code) do
    case eval_to_elixir(script_code) do
      {:ok, {result, _}} ->
        {:ok, result}

      error ->
        error
    end
  end
end

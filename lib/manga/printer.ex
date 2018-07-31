defmodule Manga.Printer do

  alias Manga.Printer.{LinuxPrinter, WindowsPrinter}
  alias Manga.Utils.{Props}

  defmacro __using__(_opts) do
    quote do
      @behaviour Manga.Printer

      defp print(text) do
        IO.write(:stdio, text)
      end

      defp print_line(line) do
        print(line <> "\n")
      end

      def echo_normal(text, [:inline]) do
        print(gen_normal_text(text))
      end

      def echo_normal(text) do
        print_line(gen_normal_text(text))
      end
    end
  end

  @callback gen_normal_text(text :: String.t()) :: String.t()


  def get_current_printer do
    case Props.get_os_name() do
      :linux -> LinuxPrinter
      :windows -> WindowsPrinter
      error -> {:error, error}
    end
  end
end

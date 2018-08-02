defmodule Manga.Printer do
  alias Manga.Printer.{LinuxPrinter, WindowsPrinter}
  alias Manga.Utils.{Props}

  #  defmacro gen_echo_include_inline(level) do
  #    quote do
  #      def unqoute(String.to_atom("echo_#{level}"))(text, [:inline]), do: print(text)
  #      def unqoute(String.to_atom("echo_#{level}"))(text), do: print_line(text)
  #    end
  #  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Manga.Printer

      defp print(text) do
        IO.write(:stdio, text)
      end

      defp print_line(line) do
        print(line <> "\n")
      end

      defp print_to_error(text) do
        IO.write(:stderr, text)
      end

      def gen_newline do
        "\n"
      end

      def newline do
        print(gen_newline())
      end

      def echo_normal(text, [:inline]) do
        print(gen_normal_text(text))
      end

      def echo_normal(text) do
        print_line(gen_normal_text(text))
      end

      def echo_info(text, [:inline]) do
        print(gen_info_text(text))
      end

      def echo_info(text) do
        print_line(gen_info_text(text))
      end

      def echo_result(text, [:inline]) do
        print(gen_result_text(text))
      end

      def echo_result(text) do
        print_line(gen_result_text(text))
      end

      def echo_error(text, [:inline]) do
        print_to_error(gen_error_text(text))
      end

      def echo_error(text) do
        print_to_error(gen_error_text(text) <> "\n")
      end

      def echo_warning(text, [:inline]) do
        print(gen_warning_text(text))
      end

      def echo_warning(text) do
        print_line(gen_warning_text(text))
      end
    end
  end

  @callback gen_normal_text(text :: String.t()) :: String.t()
  @callback gen_info_text(text :: String.t()) :: String.t()
  @callback gen_result_text(text :: String.t()) :: String.t()
  @callback gen_error_text(text :: String.t()) :: String.t()
  @callback gen_warning_text(text :: String.t()) :: String.t()
  @callback gen_newline() :: String.t()

  def get_current_printer do
    case Props.get_os_name() do
      :linux -> LinuxPrinter
      :windows -> WindowsPrinter
      error -> {:error, error}
    end
  end
end

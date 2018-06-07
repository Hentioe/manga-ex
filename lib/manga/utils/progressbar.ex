defmodule Manga.Utils.ProgressBar do
  def render(cur, tot, opts \\ []) do
    ProgressBar.render(cur, tot, opts)
  end

  def render_fetch(name, cur, tot) do
    format = [
      left: [IO.ANSI.magenta(), "FETCHING: [#{name}]", IO.ANSI.reset(), " |"]
    ]

    render(cur, tot, format)
  end

  def render_download(name, cur, tot) do
    format = [
      left: [IO.ANSI.magenta(), "DOWNLOAD: [#{name}]", IO.ANSI.reset(), " |"]
    ]

    render(cur, tot, format)
  end

  def render_export(name, cur, tot) do
    format = [
      left: [IO.ANSI.magenta(), "EXPORT  : [#{name}]", IO.ANSI.reset(), " |"]
    ]

    render(cur, tot, format)
  end

  def render_indeterminate(name, caller) do
    name = if name == nil, do: "???", else: name
    IO.write(:stdio, "\n")
    ProgressBar.render_spinner([text: "FETCHING: [#{name}]", done: "FETCHED: [#{name}]"], caller)
  end
end

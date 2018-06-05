defmodule Manga.Model.Page do
  @default_http_headers %{}
  @default_http_options []
  defstruct [:p, :url, http_headers: @default_http_headers, http_options: @default_http_options]

  def create(props) when is_list(props) do
    http_headers = Keyword.get(props, :http_headers, @default_http_headers)
    http_options = Keyword.get(props, :http_options, @default_http_options)

    %__MODULE__{
      p: props[:p],
      url: props[:url],
      http_headers: http_headers,
      http_options: http_options
    }
  end
end

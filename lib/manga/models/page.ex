defmodule Manga.Model.Page do
  @default_http_headers %{}
  @default_http_options []
  @default_img_formmat "jpg"
  @default_img_mime "image/jpeg"
  defstruct [
    :p,
    :url,
    suffix: @default_img_formmat,
    img_mime: @default_img_mime,
    http_headers: @default_http_headers,
    http_options: @default_http_options
  ]

  def create(props) when is_list(props) do
    http_headers = Keyword.get(props, :http_headers, @default_http_headers)
    http_options = Keyword.get(props, :http_options, @default_http_options)

    suffix = set_suffix(props[:url])

    %__MODULE__{
      p: props[:p],
      url: props[:url],
      suffix: suffix,
      img_mime: set_img_mime(suffix),
      http_headers: http_headers,
      http_options: http_options
    }
  end

  defp set_suffix(url) do
    if url != nil do
      suffix =
        Regex.scan(~r{^https?://.+/[^\.]+\.([^\?]+)}, url)
        |> List.first()
        |> (fn match_result ->
              if match_result == nil, do: @default_img_formmat, else: List.last(match_result)
            end).()
        |> String.split(".")
        |> List.last()

      suffix
    else
      @default_img_formmat
    end
  end

  defp set_img_mime(suffix) do
    suffix = if suffix == nil, do: nil, else: String.downcase(suffix)

    case suffix do
      nil -> @default_img_mime
      "jpg" -> "image/jpeg"
      "jpeg" -> "image/jpeg"
      "gif" -> "image/gif"
      "png" -> "image/png"
      "bmp" -> "image/bmp"
      "webp" -> "image/webp"
    end
  end
end

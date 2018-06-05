defmodule Manga.Utils.HTTPClient do
  alias HTTPotion, as: HP

  @default_user_agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"

  @default_options [
    follow_redirects: true,
    timeout: 10 * 1500,
    headers: [
      "User-Agent": @default_user_agent
    ]
  ]

  def get(url, options \\ @default_options) do
    HP.get(url, options)
  end
end

defmodule Manga.Utils.HTTPClient.Response do
  alias HTTPotion.Response, as: HPR

  def body(resp) do
    resp.body
  end

  def success?(resp) do
    case resp do
      %{message: _} -> false
      _ -> HPR.success?(resp)
    end
  end

  def status_code?(resp, status_code) do
    case resp do
      %{message: _} -> false
      _ -> resp.status_code == status_code
    end
  end

  def error_msg(resp, prefix_msg) do
    case resp do
      %{message: message} ->
        "[#{prefix_msg}] #{message}"

      %{status_code: status_code} ->
        if status_code == 20 do
          "[#{prefix_msg}] Normal state"
        else
          "[#{prefix_msg}] HTTP Status:#{status_code}"
        end
    end
  end
end

defmodule Manga.HTTPClient do
  alias HTTPotion, as: HP

  @default_user_agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36"

  @default_options [
    {
      :"user-agent",
      @default_user_agent
    }
  ]

  def get(url, options \\ @default_options) do
    HP.get(url, headers: ["User-Agent": options[:"user-agent"]])
  end
end

defmodule Manga.HTTPClient.Response do
  alias HTTPotion.Response, as: HPR

  def body(resp) do
    resp.body
  end

  def success?(resp) do
    HPR.success?(resp)
  end
end

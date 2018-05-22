defmodule Manga.Res.FZDMOrigin do
  @behaviour Manga.Res.Origin

  def search(_words) do
    {:ok,
     [
       [{:name, "进击的巨人"}, {:url, "https://manhua.fzdm.com/39/"}]
     ]}
  end

  def number_list(_manga) do
    {:ok,
     [
       [{:stage, 1}, {:url, "https://manhua.fzdm.com/39/001/"}]
     ]}
  end

  def fetch(_url) do
    {:ok,
     [
       [{:p, 1}, {:url, "http://183.91.33.78/p0.xiaoshidi.net/2013/03/171233320.jpg"}]
     ]}
  end
end

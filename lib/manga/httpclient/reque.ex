defmodule Manga.HttpClient.Reque do
  @table_id :reque

  def init do
    :ets.new(@table_id, [:named_table])
  end

  def enqueue(url, options) do
    :ets.insert(@table_id, {url, options})
  end
end

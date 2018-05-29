defmodule Manga.Utils.IOUtils do
  def mkdir_not_exists(path_list) when is_list(path_list) do
    Enum.each(path_list, fn path ->
      if !File.exists?(path) do
        File.mkdir(path)
      end
    end)
  end

  def mkdir_not_exists(path) do
    mkdir_not_exists([path])
  end
end

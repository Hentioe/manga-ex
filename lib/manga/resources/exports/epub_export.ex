defmodule Manga.Res.EpubExport do
  @behaviour Manga.Res.Export

  import Manga.Utils.IOUtils
  import Manga.Res.EpubTpl
  alias Manga.Utils.Props

  def save_from_stage(stage) do
    output_path = "./_res/EPUBs/#{stage.name}.epub"
    # 建立缓存目录
    cache_dir = "./_res/.cache/#{stage.name}"
    meta_inf_path = "#{cache_dir}/META-INF"
    mkdir_not_exists([cache_dir, meta_inf_path])
    # 写入 start.xhtml
    start_xhtml_file = "#{cache_dir}/start.xhtml"
    File.write(start_xhtml_file, start_xhtml(stage.name, stage.platform, Props.get_operator()))

    # 循环写入 xhtml 文件/复制图片
    stage.plist
    |> Enum.each(fn page ->
      "#{cache_dir}/#{page.p}.xhtml"
      |> File.write(img_xhtml("#{page.p}.jpg"))

      "_res/assets/#{stage.name}/#{page.p}.jpg"
      |> File.copy("#{cache_dir}/#{page.p}.jpg")
    end)

    # 复制第一张图为 cover.jpg
    cover_source_file = "#{cache_dir}/1.jpg"
    cover_file = "#{cache_dir}/cover.jpg"
    File.copy(cover_source_file, cover_file)

    # 写入 metadata.opf
    metadata_opf_file = "#{cache_dir}/metadata.opf"
    File.write(metadata_opf_file, metadata_opf(stage.name, length(stage.plist)))

    # 写入 mimetype
    mimetype_file = "#{cache_dir}/mimetype"
    File.write(mimetype_file, mimetype())

    # 写入 stylesheet
    stylesheet_file = "#{cache_dir}/stylesheet.css"
    File.write(stylesheet_file, stylesheet())

    # 写入 toc.ncx
    toc_ncx_file = "#{cache_dir}/toc.ncx"
    File.write(toc_ncx_file, toc_ncx(stage.name, length(stage.plist)))

    # 写入 META-INF/container.xml
    container_xml_file = "#{meta_inf_path}/container.xml"
    File.write(container_xml_file, container_xml())

    # 列表文件
    files =
      [
        cover_file,
        start_xhtml_file,
        metadata_opf_file,
        mimetype_file,
        stylesheet_file,
        toc_ncx_file,
        container_xml_file
      ]
      |> Enum.map(&String.replace(&1, "#{cache_dir}/", ""))

    files =
      files ++
        Enum.map(1..length(stage.plist), fn i ->
          "#{i}.xhtml"
        end) ++
        Enum.map(1..length(stage.plist), fn i ->
          "#{i}.jpg"
        end)

    files = files |> Enum.map(&String.to_charlist(&1))

    IO.inspect(files)

    :zip.create(output_path, files, cwd: cache_dir)
  end
end

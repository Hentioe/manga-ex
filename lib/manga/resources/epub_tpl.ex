defmodule Manga.Res.EpubTpl do
  def start_xhtml(name, platform, operator) do
    ~s{<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml" lang="zh">
<head>
  <title>#{name} - 关于</title>
  <link href="stylesheet.css" rel="stylesheet" type="text/css"/>
</head>
<body>
  <h1>版权信息</h1>
  <p>图书名：#{name}</p>
  <p>来源于：<a href="#{platform.url}">#{platform.name}</a></p>
  <p>操作人：#{operator}</p>
  <hr/>
  <p>本图书由开源项目: <a href="https://github.com/Hentioe/manga.ex">Manga.ex</a> 生成，资源来自于第三方。</p>
  <strong>注：公开传播则意味着存在被版权方追究责任的风险。</strong>
</body>
</html>}
  end

  def img_xhtml(img_src, name \\ "") do
    ~s{<?xml version='1.0' encoding='utf-8'?>
    <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>#{name}</title>
      <link href="stylesheet.css" rel="stylesheet" type="text/css"/>
    </head>
    <body class="album">
      <img class="albumimg" src="#{img_src}"/>
    </body>
    </html>}
  end

  def mimetype do
    "application/epub+zip"
  end

  def stylesheet do
    ~s/.album {
        display: block;
        padding: 0;
        margin: 0;
      }
      .albumimg {
        height: auto;
        max-height: 150%;
        max-width: 150%;
        width: auto;
      }/
  end

  def toc_ncx(name, img_count) when is_integer(img_count) do
    ~s{<?xml version='1.0' encoding='utf-8'?>
    <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="zh">
      <head>
        <meta content="#{UUID.uuid4()}" name="dtb:uid"/>
        <meta content="2" name="dtb:depth"/>
        <meta content="manga.ex (alpha)" name="dtb:generator"/>
        <meta content="0" name="dtb:totalPageCount"/>
        <meta content="0" name="dtb:maxPageNumber"/>
      </head>
      <docTitle>
        <text>#{name}</text>
      </docTitle>
      <navMap>
        <navPoint id="navPoint-0" playOrder="0">
          <navLabel>
            <text>关于</text>
          </navLabel>
          <content src="start.xhtml"/>
        </navPoint>

        <%= for i <- 1..img_count do %>
            <navPoint id="navPoint-<%= i %>" playOrder="<%= i %>">
            <navLabel>
                <text><%= i %>P</text>
            </navLabel>
            <content src="<%= i %>.xhtml"/>
            </navPoint>
        <% end %>
      </navMap>
    </ncx>}
    |> EEx.eval_string(img_count: img_count)
  end

  def metadata_opf(title, img_count) when is_integer(img_count) do
    uuid = UUID.uuid4()

    ~s{<?xml version="1.0"  encoding="UTF-8"?>
    <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="uuid_id" version="2.0">
      <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
        <dc:title>#{title}</dc:title>
        <dc:creator opf:role="aut" opf:file-as="Manga.ex">Manga.ex</dc:creator>
        <dc:identifier opf:scheme="uuid" id="uuid_id">#{uuid}</dc:identifier>
        <dc:contributor opf:file-as="manga.ex" opf:role="bkp">manga.ex (alpha) [https://github.com/Hentioe/manga.ex]</dc:contributor>
        <dc:date>0101-01-01T00:00:00+00:00</dc:date>
        <dc:language>zh</dc:language>
        <dc:identifier opf:scheme="calibre">#{uuid}</dc:identifier>
        <meta name="calibre:title_sort" content="#{title}"/>
        <meta name="calibre:author_link_map" content="\{&quot;Manga.ex&quot;: &quot;&quot;\}"/>
      </metadata>
      <manifest>
        <item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml"/>
        <item href="stylesheet.css" id="id33" media-type="text/css"/>
        <item href="start.xhtml" id="start" media-type="application/xhtml+xml"/>
    <%= for i <- 1..img_count do %>
        <item href="<%= i %>.xhtml" id="page<%= i %>" media-type="application/xhtml+xml"/>
        <item href="<%= i %>.jpg" id="img<%= i %>" media-type="image/jpeg"/>
    <% end %>
      </manifest>
      <spine toc="ncx">
        <itemref idref="start"/>
    <%= for i <- 1..img_count do %>
        <itemref idref="page<%= i %>"/>
    <% end %>
      </spine>
      <guide/>
    </package>}
    |> EEx.eval_string(img_count: img_count)
  end

  def container_xml do
    ~s{<?xml version='1.0' encoding='utf-8'?>
    <container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0">
      <rootfiles>
        <rootfile full-path="metadata.opf" media-type="application/oebps-package+xml"/>
      </rootfiles>
    </container>}
  end
end

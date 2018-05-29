defmodule Manga.Res.EpubTpl do
  def img_xhtml(img_src, title \\ "", alt \\ "") do
    '
    <?xml version=\'1.0\' encoding=\'utf-8\'?>
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>#{title}</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
      <link href="stylesheet.css" rel="stylesheet" type="text/css"/>
      </head>
      <body class="album">
        <div>
          <img src="#{img_src}" class="albumimg" alt="#{alt}"/>
        </div>
      </body>
    </html>
    ' |> List.to_string()
  end

  def mimetype do
    "application/epub+zip"
  end

  def stylesheet do
    "
    .album {
        display: block;
        font-size: 1em;
        padding: 0;
        margin: 0;
    }
    .albumimg {
        height: auto;
        max-height: 100%;
        max-width: 100%;
        width: auto
    }
    "
  end

  def toc_ncx do
    '
    <?xml version=\'1.0\' encoding=\'utf-8\'?>
    <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="eng">
    <head>
        <meta content="#{UUID.uuid4()}" name="dtb:uid"/>
        <meta content="2" name="dtb:depth"/>
        <meta content="ruamel.jpeg2epub (0.1)" name="dtb:generator"/>
        <meta content="0" name="dtb:totalPageCount"/>
        <meta content="0" name="dtb:maxPageNumber"/>
    </head>
    <docTitle>
        <text>xx</text>
    </docTitle>
    <navMap>
        <navPoint id="#{UUID.uuid4()}" playOrder="1">
        <navLabel>
            <text>Start</text>
        </navLabel>
        <content src="1.xhtml"/>
        </navPoint>
    </navMap>
    </ncx>
    ' |> List.to_string()
  end

  @default_c_opf_options [
    title_sort: "no titlt sort",
    creator: "Manga.ex"
  ]

  def c_opf(title, res_length, options \\ @default_c_opf_options) do
    uuid = UUID.uuid4()
    '
    <?xml version=\'1.0\' encoding=\'utf-8\'?>
    <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="uuid_id" version="2.0">
        <metadata xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf"
                    xmlns:dcterms="http://purl.org/dc/terms/"
                    xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata"
                    xmlns:dc="http://purl.org/dc/elements/1.1/">
            <dc:language>en</dc:language>
            <dc:creator>#{options[:creator]}</dc:creator>
            <meta name="calibre:timestamp" content="#{DateTime.utc_now() |> DateTime.to_string()}"/>
            <meta name="calibre:title_sort" content="#{options[:title_sort]}"/>
            <meta name="cover" content="cover"/>
            <dc:date>0101-01-01T00:00:00+00:00</dc:date>
            <dc:title>#{title}</dc:title>
            <dc:identifier id="uid_id" opf:scheme="uuid">#{uuid}</dc:identifier>
            <dc:identifier opf:scheme="calibre">#{uuid}</dc:identifier>
        </metadata>
        <manifest>
            <item href="stylesheet.css" id="css" media-type="text/css"/>
        <%= for i <- 1..res_length do %>
            <item href="<%= i %>.xhtml" id="html<%= i %>" media-type="application/xhtml+xml"/>
            <item href="<%= i %>.jpg" id="img<%= i %>" media-type="image/jpeg"/>
        <% end %>
            
            <item href="toc.ncx" id="ncx" media-type="application/x-dtbncx+xml"/>
        </manifest>
        <spine toc="ncx">
        <%= for i <- 0..res_length do %>
            <itemref idref="html<%= i %>"/>
        <% end %>
        </spine>
    </package>      
    ' |> List.to_string() |> EEx.eval_string(res_length: res_length)
  end

  def container_xml do
    '
    <?xml version="1.0"?>
    <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
        <rootfiles>
            <rootfile full-path="c.opf" media-type="application/oebps-package+xml"/>
        </rootfiles>
    </container>
    ' |> List.to_string()
  end
end

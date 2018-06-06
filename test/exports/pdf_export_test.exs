defmodule Manga.Res.EpubExportTest do
  use ExUnit.Case

  test "save_from_stage" do
    {alpaca_alias, alpaca_rendition} = Gutenex.PDF.Images.load("./alpaca.png")

    {:ok, pid} = Gutenex.start_link
  Gutenex.add_image(pid, alpaca_alias, alpaca_rendition)
    |> Gutenex.begin_text
    |> Gutenex.set_font("Helvetica", 48)
    |> Gutenex.text_position(40, 180)
    |> Gutenex.text_render_mode(:fill)
    |> Gutenex.write_text("ABC")
    |> Gutenex.set_font("Courier", 32)
    |> Gutenex.text_render_mode(:stroke)
    |> Gutenex.write_text("xyz")
    |> Gutenex.end_text
    |> Gutenex.move_to(400, 20)
    |> Gutenex.draw_image(alpaca_alias, %{
      translate_x: 300,
      translate_y: 500,
    })
    |> Gutenex.export("./tmp/alpaca.pdf")
    |> Gutenex.stop
  end
end

# frozen_string_literal: true

# examples/render_waterfall.rb — Render a variable font waterfall to HTML
#
# Usage: ruby examples/render_waterfall.rb /path/to/variable_font.ttf [text]
#
# Generates an HTML file with SVG renderings of text at different
# variable font axis values and opens it in the default browser.
#
# Download a variable font from https://fonts.google.com/variablefonts
# e.g. Roboto Flex, Inter, or Noto Sans

require "harfbuzz"

font_path = ARGV[0]
unless font_path && File.exist?(font_path)
  puts "Usage: ruby examples/render_waterfall.rb /path/to/variable_font.ttf [text]"
  puts
  puts "Download a variable font from https://fonts.google.com/variablefonts"
  exit 1
end

text = ARGV[1] || "AaBbCcDdEeFf"

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
upem = face.upem

unless HarfBuzz::OT::Var.has_data?(face)
  puts "Error: #{font_path} is not a variable font."
  exit 1
end

axes = HarfBuzz::OT::Var.axis_infos(face)
wght_axis = axes.find { |a| HarfBuzz.tag_to_s(a[:tag]).strip == "wght" }
unless wght_axis
  puts "Error: Font has no 'wght' axis."
  exit 1
end

# Generate weight steps
min_w = wght_axis[:min_value]
max_w = wght_axis[:max_value]
steps = 7
weights = (0...steps).map { |i| (min_w + (max_w - min_w) * i / (steps - 1)).round }

# Set up draw funcs
draw = HarfBuzz::DrawFuncs.new
draw_commands = []

draw.on_move_to      { |x, y| draw_commands << "M#{x.round(2)},#{(-y).round(2)}" }
draw.on_line_to      { |x, y| draw_commands << "L#{x.round(2)},#{(-y).round(2)}" }
draw.on_quadratic_to { |cx, cy, x, y|
  draw_commands << "Q#{cx.round(2)},#{(-cy).round(2)},#{x.round(2)},#{(-y).round(2)}"
}
draw.on_cubic_to { |c1x, c1y, c2x, c2y, x, y|
  draw_commands << "C#{c1x.round(2)},#{(-c1y).round(2)},#{c2x.round(2)},#{(-c2y).round(2)},#{x.round(2)},#{(-y).round(2)}"
}
draw.on_close_path { draw_commands << "Z" }
draw.make_immutable!

def shape_to_svg(font, face, text, draw, draw_commands)
  upem = face.upem
  buffer = HarfBuzz::Buffer.new
  buffer.add_utf8(text)
  buffer.guess_segment_properties
  HarfBuzz.shape(font, buffer)

  infos = buffer.glyph_infos
  positions = buffer.glyph_positions

  svg_paths = []
  cursor_x = 0

  infos.zip(positions).each do |info, pos|
    draw_commands.clear
    font.draw_glyph(info.glyph_id, draw)

    unless draw_commands.empty?
      ox = cursor_x + pos.x_offset
      oy = pos.y_offset
      svg_paths << %(<path transform="translate(#{ox},#{(-oy)})" d="#{draw_commands.join}" />)
    end

    cursor_x += pos.x_advance
  end

  extents = font.extents_for_direction(:ltr)
  ascender = extents[:ascender]
  descender = extents[:descender]
  height = ascender - descender
  total_advance = positions.sum(&:x_advance)

  margin = (upem * 0.08).round
  vb_x = -margin
  vb_y = -(ascender + margin)
  vb_w = total_advance + margin * 2
  vb_h = height + margin * 2

  pixel_height = 48
  pixel_width = (vb_w.to_f / vb_h * pixel_height).round

  <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg"
         viewBox="#{vb_x} #{vb_y} #{vb_w} #{vb_h}"
         width="#{pixel_width}" height="#{pixel_height}">
      <g fill="black">#{svg_paths.join}</g>
    </svg>
  SVG
end

# Render each weight
rows = weights.map do |w|
  font = HarfBuzz::Font.new(face)
  variation = HarfBuzz::Variation.from_string("wght=#{w}")
  font.variations = [variation]

  svg = shape_to_svg(font, face, text, draw, draw_commands)
  { weight: w, svg: svg }
end

# Build HTML
tag_name = HarfBuzz.tag_to_s(wght_axis[:tag]).strip
html = <<~HTML
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>HarfBuzz Variable Font Waterfall</title>
    <style>
      body {
        font-family: system-ui, sans-serif;
        max-width: 900px;
        margin: 40px auto;
        padding: 0 20px;
        background: #fafafa;
        color: #333;
      }
      h1 { font-size: 1.4em; margin-bottom: 0.3em; }
      p.meta { color: #888; font-size: 0.9em; margin-top: 0; }
      table { border-collapse: collapse; width: 100%; margin-top: 20px; }
      th, td { text-align: left; padding: 10px 16px; border-bottom: 1px solid #eee; }
      th { color: #999; font-weight: normal; font-size: 0.85em; text-transform: uppercase; }
      td.weight { font-variant-numeric: tabular-nums; font-size: 0.95em; width: 80px; }
      td.render svg { display: block; }
    </style>
  </head>
  <body>
    <h1>Variable Font Waterfall</h1>
    <p class="meta">
      Font: #{File.basename(font_path)}<br>
      Axis: #{tag_name} (#{min_w.round}–#{max_w.round})<br>
      Text: "#{text}"
    </p>
    <table>
      <tr><th>#{tag_name}</th><th>Rendered</th></tr>
      #{rows.map { |r| "<tr><td class=\"weight\">#{r[:weight]}</td><td class=\"render\">#{r[:svg]}</td></tr>" }.join("\n      ")}
    </table>
  </body>
  </html>
HTML

output_path = File.expand_path("waterfall_output.html", __dir__)
File.write(output_path, html)
puts "HTML written to #{output_path}"
puts "  Font: #{font_path}"
puts "  Axis: #{tag_name} (#{min_w.round}–#{max_w.round}), #{steps} steps"
puts "  Text: #{text}"

case RUBY_PLATFORM
when /darwin/
  system("open", output_path)
when /linux/
  system("xdg-open", output_path)
when /mingw|mswin/
  system("start", output_path)
end

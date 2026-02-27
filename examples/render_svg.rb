# frozen_string_literal: true

# examples/render_svg.rb — Render shaped text to an SVG file and open it
#
# Usage: ruby examples/render_svg.rb [text] [path/to/font.ttf]
#
# Generates an SVG file from shaped text using glyph outlines and opens
# it in the default browser.

require "harfbuzz"

text = ARGV[0] || "Hello, HarfBuzz!"
font_path = ARGV[1] ||
  if File.exist?("/System/Library/Fonts/Helvetica.ttc")
    "/System/Library/Fonts/Helvetica.ttc"
  elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  else
    raise "No font found. Pass font path as argument."
  end

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)
upem = face.upem

# Set up draw funcs for outline extraction
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

# Shape the text
buffer = HarfBuzz::Buffer.new
buffer.add_utf8(text)
buffer.guess_segment_properties
HarfBuzz.shape(font, buffer)

infos = buffer.glyph_infos
positions = buffer.glyph_positions

# Build SVG path elements for each glyph
svg_paths = []
cursor_x = 0
cursor_y = 0

infos.zip(positions).each do |info, pos|
  draw_commands.clear
  font.draw_glyph(info.glyph_id, draw)

  unless draw_commands.empty?
    ox = cursor_x + pos.x_offset
    oy = cursor_y + pos.y_offset
    svg_paths << %(<path transform="translate(#{ox},#{(-oy)})" d="#{draw_commands.join}" />)
  end

  cursor_x += pos.x_advance
  cursor_y += pos.y_advance
end

# Get font metrics for viewBox
extents = font.extents_for_direction(:ltr)
ascender = extents[:ascender]
descender = extents[:descender]
height = ascender - descender
total_advance = positions.sum(&:x_advance)

margin = (upem * 0.1).round
vb_x = -margin
vb_y = -(ascender + margin)
vb_w = total_advance + margin * 2
vb_h = height + margin * 2

svg = <<~SVG
  <?xml version="1.0" encoding="UTF-8"?>
  <svg xmlns="http://www.w3.org/2000/svg"
       viewBox="#{vb_x} #{vb_y} #{vb_w} #{vb_h}"
       width="#{(vb_w.to_f / upem * 64).round}" height="#{(vb_h.to_f / upem * 64).round}">
    <rect x="#{vb_x}" y="#{vb_y}" width="#{vb_w}" height="#{vb_h}" fill="white" />
    <line x1="#{vb_x}" y1="0" x2="#{vb_x + vb_w}" y2="0" stroke="#ccc" stroke-width="#{upem * 0.005}" />
    <g fill="black">
      #{svg_paths.join("\n    ")}
    </g>
  </svg>
SVG

output_path = File.expand_path("render_output.svg", __dir__)
File.write(output_path, svg)
puts "SVG written to #{output_path}"
puts "  Text: #{text}"
puts "  Font: #{font_path}"
puts "  Glyphs: #{infos.length}"
puts "  Total advance: #{total_advance} (#{upem} upem)"

# Open in default browser
case RUBY_PLATFORM
when /darwin/
  system("open", output_path)
when /linux/
  system("xdg-open", output_path)
when /mingw|mswin/
  system("start", output_path)
end

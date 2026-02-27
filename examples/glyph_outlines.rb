# frozen_string_literal: true

# examples/glyph_outlines.rb — Extract glyph outlines using DrawFuncs
#
# Usage: ruby examples/glyph_outlines.rb [path/to/font.ttf]

require "harfbuzz"

font_path = ARGV[0] ||
  if File.exist?("/System/Library/Fonts/Helvetica.ttc")
    "/System/Library/Fonts/Helvetica.ttc"
  elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  else
    raise "No font found. Pass font path as argument."
  end

puts "=== Glyph Outline Extraction ==="
puts

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)

# --- Set up DrawFuncs ---
draw = HarfBuzz::DrawFuncs.new

commands = []

draw.on_move_to do |x, y, _draw_state|
  commands << "M #{x.round(2)},#{y.round(2)}"
end

draw.on_line_to do |x, y, _draw_state|
  commands << "L #{x.round(2)},#{y.round(2)}"
end

draw.on_quadratic_to do |cx, cy, x, y, _draw_state|
  commands << "Q #{cx.round(2)},#{cy.round(2)} #{x.round(2)},#{y.round(2)}"
end

draw.on_cubic_to do |c1x, c1y, c2x, c2y, x, y, _draw_state|
  commands << "C #{c1x.round(2)},#{c1y.round(2)} #{c2x.round(2)},#{c2y.round(2)} #{x.round(2)},#{y.round(2)}"
end

draw.on_close_path do |_draw_state|
  commands << "Z"
end

draw.make_immutable!

# --- Shape text and get glyph IDs ---
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("AB")
buffer.guess_segment_properties
HarfBuzz.shape(font, buffer)

# --- Extract outline for each glyph ---
buffer.glyph_infos.each do |info|
  commands.clear
  font.draw_glyph(info.glyph_id, draw)
  puts "Glyph #{info.glyph_id} (cluster #{info.cluster}):"
  if commands.empty?
    puts "  (no outline — space or missing)"
  else
    puts "  SVG path: #{commands.join(" ")}"
    puts "  Commands: #{commands.length}"
  end
  puts
end

# --- Glyph extents ---
puts "--- Glyph Extents ---"
buffer.glyph_infos.each do |info|
  extents = font.glyph_extents(info.glyph_id)
  if extents
    puts "Glyph #{info.glyph_id}: x_bearing=#{extents[:x_bearing]} y_bearing=#{extents[:y_bearing]} width=#{extents[:width]} height=#{extents[:height]}"
  end
end

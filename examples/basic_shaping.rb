# frozen_string_literal: true

# examples/basic_shaping.rb — Basic text shaping with HarfBuzz
#
# Usage: ruby examples/basic_shaping.rb [path/to/font.ttf]

require "harfbuzz"

font_path = ARGV[0] ||
  if File.exist?("/System/Library/Fonts/Helvetica.ttc")
    "/System/Library/Fonts/Helvetica.ttc"
  elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  else
    raise "No font found. Pass font path as argument."
  end

puts "=== Basic Shaping ==="
puts "HarfBuzz #{HarfBuzz.version_string}"
puts

# --- One-liner API ---
puts "--- shape_text (one-liner) ---"
result = HarfBuzz.shape_text("Hello, World!", font_path: font_path)
puts "Glyphs: #{result.length}"
result.each do |info, pos|
  puts "  glyph=#{info.glyph_id} cluster=#{info.cluster} x_advance=#{pos.x_advance}"
end
puts "Total X advance: #{result.total_advance.first}"
puts

# --- Manual API ---
puts "--- Manual Buffer + Font API ---"
blob   = HarfBuzz::Blob.from_file!(font_path)
face   = HarfBuzz::Face.new(blob, 0)
font   = HarfBuzz::Font.new(face)
buffer = HarfBuzz::Buffer.new

buffer.add_utf8("Ruby")
buffer.guess_segment_properties
HarfBuzz.shape(font, buffer)

puts "Shaped '#{buffer.serialize}'"
puts "Glyph count: #{buffer.length}"
buffer.glyph_infos.zip(buffer.glyph_positions).each do |info, pos|
  puts "  glyph_id=#{info.glyph_id} x_advance=#{pos.x_advance} y_advance=#{pos.y_advance}"
end
puts

# --- Buffer reuse pattern ---
puts "--- Buffer reuse ---"
texts = ["Hello", "World", "Ruby", "HarfBuzz"]
texts.each do |text|
  buffer.reset
  buffer.add_utf8(text)
  buffer.guess_segment_properties
  HarfBuzz.shape(font, buffer)
  total_advance = buffer.glyph_positions.sum(&:x_advance)
  puts "  '#{text}': #{buffer.length} glyphs, total_advance=#{total_advance}"
end
puts

# --- RTL shaping ---
puts "--- RTL (Arabic) ---"
arabic_result = HarfBuzz.shape_text("مرحبا", font_path: font_path, direction: :rtl)
puts "Arabic glyphs: #{arabic_result.length}"
puts "Direction detected: #{HarfBuzz::Buffer.new.tap { |b| b.add_utf8("مرحبا"); b.guess_segment_properties }.direction}"

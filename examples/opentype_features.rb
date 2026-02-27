# frozen_string_literal: true

# examples/opentype_features.rb — OpenType feature queries and shaping with features
#
# Usage: ruby examples/opentype_features.rb [path/to/font.ttf]

require "harfbuzz"

font_path = ARGV[0] ||
  if File.exist?("/System/Library/Fonts/Helvetica.ttc")
    "/System/Library/Fonts/Helvetica.ttc"
  elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  else
    raise "No font found. Pass font path as argument."
  end

puts "=== OpenType Features ==="
puts

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)

# --- List GSUB scripts ---
puts "--- GSUB Scripts ---"
begin
  scripts = HarfBuzz::OT::Layout.script_tags(face, :gsub)
  puts "Scripts: #{scripts.map { |t| HarfBuzz.tag_to_s(t) }.inspect}"
rescue => e
  puts "  (#{e.message})"
end
puts

# --- List GSUB features for default script ---
puts "--- GSUB Features (first script/language) ---"
begin
  features = HarfBuzz::OT::Layout.feature_tags(face, :gsub, 0, 0)
  puts "Features: #{features.map { |t| HarfBuzz.tag_to_s(t) }.first(10).inspect}"
rescue => e
  puts "  (#{e.message})"
end
puts

# --- Shaping with explicit features ---
puts "--- Shaping with Features ---"
font2 = HarfBuzz::Font.new(face)

buf_with_liga = HarfBuzz::Buffer.new
buf_with_liga.add_utf8("fi")
buf_with_liga.guess_segment_properties
HarfBuzz.shape(font2, buf_with_liga, [HarfBuzz::Feature.from_string("liga")])
puts "With liga: #{buf_with_liga.length} glyph(s)"

buf_no_liga = HarfBuzz::Buffer.new
buf_no_liga.add_utf8("fi")
buf_no_liga.guess_segment_properties
HarfBuzz.shape(font2, buf_no_liga, [HarfBuzz::Feature.from_string("-liga")])
puts "Without liga: #{buf_no_liga.length} glyph(s)"
puts

# --- Feature from hash ---
puts "--- Feature from Hash ---"
features = HarfBuzz::Feature.from_hash(liga: true, kern: false)
puts "Features: #{features.map(&:to_s).inspect}"
puts

# --- Glyph class query ---
puts "--- Glyph Classes ---"
begin
  has_classes = HarfBuzz::OT::Layout.has_glyph_classes?(face)
  puts "Has glyph classes: #{has_classes}"
  if has_classes
    klass = HarfBuzz::OT::Layout.glyph_class(face, 65) # 'A'
    puts "  Glyph class of glyph 65: #{klass}"
  end
rescue => e
  puts "  (#{e.message})"
end
puts

# --- OT Metrics ---
puts "--- OT Metrics ---"
begin
  x_height = HarfBuzz::OT::Metrics.x_height(font)
  puts "x-height: #{x_height}"
  cap_height = HarfBuzz::OT::Metrics.cap_height(font)
  puts "cap-height: #{cap_height}"
rescue => e
  puts "  (#{e.message})"
end

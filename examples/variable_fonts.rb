# frozen_string_literal: true

# examples/variable_fonts.rb — Variable font axis queries and shaping
#
# Usage: ruby examples/variable_fonts.rb /path/to/variable_font.ttf
#
# A variable font is required. Download one from Google Fonts, e.g.:
#   https://fonts.google.com/specimen/Roboto+Flex

require "harfbuzz"

font_path = ARGV[0]
unless font_path && File.exist?(font_path)
  puts "Usage: ruby examples/variable_fonts.rb /path/to/variable_font.ttf"
  puts
  puts "Download a variable font from https://fonts.google.com/variablefonts"
  exit 1
end

puts "=== Variable Fonts ==="
puts "Font: #{font_path}"
puts

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)

# --- Check if font has variation data ---
puts "--- Variation Axes ---"
if HarfBuzz::OT::Var.has_data?(face)
  axes = HarfBuzz::OT::Var.axis_infos(face)
  puts "#{axes.length} axes found:"
  axes.each do |axis|
    tag_str = HarfBuzz.tag_to_s(axis[:tag])
    puts "  #{tag_str}: min=#{axis[:min_value]} default=#{axis[:default_value]} max=#{axis[:max_value]}"
  end
else
  puts "This font has no variation data."
  exit 0
end
puts

# --- Named instances ---
puts "--- Named Instances ---"
count = HarfBuzz::OT::Var.named_instance_count(face)
puts "#{count} named instances"
count.times do |i|
  coords = HarfBuzz::OT::Var.named_instance_design_coords(face, i)
  puts "  Instance #{i}: #{coords.inspect}"
end
puts

# --- Apply variation to font ---
puts "--- Applying Variations ---"
axes = HarfBuzz::OT::Var.axis_infos(face)
if axes.any?
  wght_axis = axes.find { |a| HarfBuzz.tag_to_s(a[:tag]).strip == "wght" }
  if wght_axis
    puts "Setting weight to max (#{wght_axis[:max_value]})"
    variation = HarfBuzz::Variation.from_string("wght=#{wght_axis[:max_value]}")
    font.variations = [variation]
  end
end

# Shape with varied font
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("Hello")
buffer.guess_segment_properties
HarfBuzz.shape(font, buffer)
puts "Shaped with variation: #{buffer.length} glyphs"
buffer.glyph_positions.each do |pos|
  puts "  x_advance=#{pos.x_advance}"
end

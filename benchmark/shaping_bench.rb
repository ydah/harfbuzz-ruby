# frozen_string_literal: true

# benchmark/shaping_bench.rb — HarfBuzz Ruby FFI shaping benchmarks
#
# Usage:
#   bundle exec ruby benchmark/shaping_bench.rb [path/to/font.ttf]
#
# Requires benchmark-ips gem: gem install benchmark-ips

require "benchmark/ips"
require "harfbuzz"

font_path = ARGV[0] ||
  if File.exist?("/System/Library/Fonts/Helvetica.ttc")
    "/System/Library/Fonts/Helvetica.ttc"
  elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  else
    raise "No test font found. Pass font path as argument: ruby benchmark/shaping_bench.rb /path/to/font.ttf"
  end

puts "HarfBuzz version: #{HarfBuzz.version_string}"
puts "Font: #{font_path}"
puts

blob = HarfBuzz::Blob.from_file!(font_path)
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)
font.make_immutable!

iteration_buffer = HarfBuzz::Buffer.new
iteration_buffer.add_utf8("Hello World " * 20)
iteration_buffer.guess_segment_properties
HarfBuzz.shape(font, iteration_buffer)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("shape Latin 10 chars") do
    buf = HarfBuzz::Buffer.new
    buf.add_utf8("Hello Word")
    buf.guess_segment_properties
    HarfBuzz.shape(font, buf)
  end

  x.report("shape Latin 100 chars") do
    buf = HarfBuzz::Buffer.new
    buf.add_utf8("a" * 100)
    buf.guess_segment_properties
    HarfBuzz.shape(font, buf)
  end

  x.report("shape with buffer reuse") do |times|
    buf = HarfBuzz::Buffer.new
    times.times do
      buf.clear
      buf.add_utf8("Hello Word")
      buf.guess_segment_properties
      HarfBuzz.shape(font, buf)
    end
  end

  x.report("iterate glyph wrappers") do
    total = 0
    infos = iteration_buffer.glyph_infos
    clusters = infos.map(&:cluster)
    infos.zip(iteration_buffer.glyph_positions).each_with_index do |(info, position), index|
      next_cluster = clusters[(index + 1)..]&.find { |cluster| cluster != info.cluster }
      total += info.glyph_id
      total += info.cluster
      total += next_cluster || 0
      total += position.x_advance
      total += position.y_advance
      total += position.x_offset
      total += position.y_offset
    end
    total
  end

  x.report("iterate each_glyph") do
    total = 0
    iteration_buffer.each_glyph do |glyph_id, cluster, next_cluster, x_advance, y_advance, x_offset, y_offset|
      total += glyph_id
      total += cluster
      total += next_cluster || 0
      total += x_advance
      total += y_advance
      total += x_offset
      total += y_offset
    end
    total
  end

  x.report("create + destroy buffer") do
    HarfBuzz::Buffer.new
  end

  x.report("glyph outline extraction") do
    draw = HarfBuzz::DrawFuncs.new
    draw.on_move_to { |_x, _y, _| }
    draw.on_line_to { |_x, _y, _| }
    draw.on_cubic_to { |*_args| }
    draw.on_close_path { |_| }
    draw.make_immutable!
    font.draw_glyph(36, draw)
  end

  x.report("shape_text one-liner") do
    HarfBuzz.shape_text("Hello", font_path: font_path)
  end

  x.compare!
end

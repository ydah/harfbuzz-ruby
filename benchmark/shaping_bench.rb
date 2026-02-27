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

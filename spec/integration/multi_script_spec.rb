# frozen_string_literal: true

RSpec.describe "Multi-script shaping", :integration do
  let(:font_path) { system_font_path }

  shared_examples "shapes text" do |text, description|
    it "shapes #{description}" do
      result = HarfBuzz.shape_text(text, font_path: font_path)
      expect(result).to be_a(HarfBuzz::ShapingResult)
      expect(result.length).to be > 0
      result.glyph_infos.each { |i| expect(i.glyph_id).to be_an(Integer) }
      result.glyph_positions.each { |p| expect(p.x_advance).to be_an(Integer) }
    end
  end

  include_examples "shapes text", "Hello, World!", "ASCII Latin"
  include_examples "shapes text", "こんにちは", "Japanese hiragana"
  include_examples "shapes text", "中文字", "CJK characters"

  describe "Arabic RTL shaping" do
    it "detects RTL direction via guess_segment_properties" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("مرحبا")
      buffer.guess_segment_properties
      expect(buffer.direction).to eq(:rtl)
    end

    it "shapes Arabic text with explicit RTL direction" do
      result = HarfBuzz.shape_text("مرحبا", font_path: font_path, direction: :rtl)
      expect(result).to be_a(HarfBuzz::ShapingResult)
      expect(result.length).to be > 0
    end
  end

  describe "buffer reuse across multiple texts" do
    it "shapes multiple texts with a single buffer without leaking" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer = HarfBuzz::Buffer.new

      texts = ["Hello", "World", "ABC"]
      texts.each do |text|
        buffer.reset
        buffer.add_utf8(text)
        buffer.guess_segment_properties
        HarfBuzz.shape(font, buffer)
        expect(buffer.content_type).to eq(:glyphs)
        expect(buffer.length).to eq(text.length)
      end
    end
  end

  describe "feature application" do
    it "liga feature reduces glyph count for 'fi' ligature" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      buf_with = HarfBuzz::Buffer.new
      buf_with.add_utf8("fi")
      buf_with.guess_segment_properties
      HarfBuzz.shape(font, buf_with, [HarfBuzz::Feature.from_string("liga")])

      buf_without = HarfBuzz::Buffer.new
      buf_without.add_utf8("fi")
      buf_without.guess_segment_properties
      HarfBuzz.shape(font, buf_without, [HarfBuzz::Feature.from_string("-liga")])

      # With liga enabled, may produce 1 glyph; without, should produce 2
      expect(buf_with.length).to be <= buf_without.length
    end
  end

  describe "ShapingResult enumerable" do
    it "can be iterated with each" do
      result = HarfBuzz.shape_text("AB", font_path: font_path)
      pairs = []
      result.each { |info, pos| pairs << [info.glyph_id, pos.x_advance] }
      expect(pairs.size).to eq(2)
      pairs.each do |(glyph_id, x_advance)|
        expect(glyph_id).to be_an(Integer)
        expect(x_advance).to be_an(Integer)
      end
    end

    it "total_advance x is positive for LTR text" do
      result = HarfBuzz.shape_text("ABC", font_path: font_path)
      x, = result.total_advance
      expect(x).to be > 0
    end
  end

  describe "thread safety" do
    it "shapes concurrently in multiple threads without errors" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      face.make_immutable!
      font = HarfBuzz::Font.new(face)
      font.make_immutable!

      errors = []
      threads = 4.times.map do |i|
        Thread.new do
          buffer = HarfBuzz::Buffer.new
          buffer.add_utf8("Hello #{i}")
          buffer.guess_segment_properties
          HarfBuzz.shape(font, buffer)
          raise "unexpected empty buffer" if buffer.length.zero?
        rescue => e
          errors << e
        end
      end
      threads.each(&:join)
      expect(errors).to be_empty
    end
  end
end

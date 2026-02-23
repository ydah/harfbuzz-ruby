# frozen_string_literal: true

RSpec.describe "HarfBuzz shaping", :integration do
  let(:font_path) { system_font_path }

  describe "HarfBuzz.shape" do
    it "shapes ASCII text" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("Hello, World!")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)

      expect(buffer.content_type).to eq(:glyphs)
      expect(buffer.length).to be > 0

      infos = buffer.glyph_infos
      expect(infos).not_to be_empty
      infos.each do |info|
        expect(info.glyph_id).to be_an(Integer)
        expect(info.cluster).to be_an(Integer)
      end

      positions = buffer.glyph_positions
      expect(positions).not_to be_empty
      positions.each do |pos|
        expect(pos.x_advance).to be_an(Integer)
        expect(pos.y_advance).to be_an(Integer)
      end
    end

    it "shapes with explicit features" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("fi")
      buffer.guess_segment_properties

      features = [HarfBuzz::Feature.from_string("liga")]
      HarfBuzz.shape(font, buffer, features)

      expect(buffer.content_type).to eq(:glyphs)
    end
  end

  describe "HarfBuzz.shape_text" do
    it "returns a ShapingResult" do
      result = HarfBuzz.shape_text("Hello", font_path: font_path)
      expect(result).to be_a(HarfBuzz::ShapingResult)
      expect(result.length).to be > 0
    end

    it "respects direction" do
      result = HarfBuzz.shape_text("مرحبا", font_path: font_path, direction: :rtl)
      expect(result).to be_a(HarfBuzz::ShapingResult)
    end

    it "accepts feature hash" do
      result = HarfBuzz.shape_text("fi", font_path: font_path, features: { liga: true })
      expect(result).to be_a(HarfBuzz::ShapingResult)
    end

    it "accepts feature string array" do
      result = HarfBuzz.shape_text("fi", font_path: font_path, features: ["liga"])
      expect(result).to be_a(HarfBuzz::ShapingResult)
    end

    it "total_advance is positive for non-empty text" do
      result = HarfBuzz.shape_text("AB", font_path: font_path)
      x_advance, = result.total_advance
      expect(x_advance).to be > 0
    end
  end

  describe "full shaping pipeline" do
    it "shapes and extracts glyph names" do
      blob = HarfBuzz::Blob.from_file!(font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("ABC")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)

      buffer.glyph_infos.each do |info|
        name = font.glyph_name(info.glyph_id)
        expect(name).to be_a(String)
      end
    end
  end
end

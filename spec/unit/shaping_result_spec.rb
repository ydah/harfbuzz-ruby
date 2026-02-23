# frozen_string_literal: true

RSpec.describe HarfBuzz::ShapingResult do
  let(:blob)   { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face)   { HarfBuzz::Face.new(blob, 0) }
  let(:font)   { HarfBuzz::Font.new(face) }
  let(:buffer) do
    buf = HarfBuzz::Buffer.new
    buf.add_utf8("Hi")
    buf.guess_segment_properties
    HarfBuzz.shape(font, buf)
    buf
  end

  subject(:result) { described_class.new(buffer: buffer, font: font) }

  describe "#length / #size" do
    it "returns the glyph count" do
      expect(result.length).to eq(2)
      expect(result.size).to eq(2)
    end
  end

  describe "#glyph_infos" do
    it "returns an array of GlyphInfo" do
      infos = result.glyph_infos
      expect(infos).to be_an(Array)
      infos.each { |i| expect(i).to be_a(HarfBuzz::GlyphInfo) }
    end
  end

  describe "#glyph_positions" do
    it "returns an array of GlyphPosition" do
      positions = result.glyph_positions
      expect(positions).to be_an(Array)
      positions.each { |p| expect(p).to be_a(HarfBuzz::GlyphPosition) }
    end
  end

  describe "#each" do
    it "yields [GlyphInfo, GlyphPosition] pairs" do
      result.each do |info, pos|
        expect(info).to be_a(HarfBuzz::GlyphInfo)
        expect(pos).to be_a(HarfBuzz::GlyphPosition)
      end
    end

    it "is Enumerable" do
      pairs = result.map { |info, pos| [info.glyph_id, pos.x_advance] }
      expect(pairs.size).to eq(2)
    end
  end

  describe "#total_advance" do
    it "returns [x_advance, y_advance]" do
      adv = result.total_advance
      expect(adv).to be_an(Array)
      expect(adv.size).to eq(2)
      expect(adv[0]).to be > 0  # horizontal advance should be positive
    end
  end

  describe "#to_svg_path" do
    it "returns a string" do
      expect(result.to_svg_path).to be_a(String)
    end
  end

  describe "#inspect" do
    it "includes length and total_advance" do
      s = result.inspect
      expect(s).to include("HarfBuzz::ShapingResult")
      expect(s).to include("length=")
      expect(s).to include("total_advance=")
    end
  end
end

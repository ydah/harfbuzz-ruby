# frozen_string_literal: true

RSpec.describe HarfBuzz::Font do
  let(:blob) { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face) { HarfBuzz::Face.new(blob, 0) }

  subject(:font) { described_class.new(face) }

  describe ".new" do
    it "creates a font from a face" do
      expect(font).to be_a(described_class)
    end
  end

  describe "#scale" do
    it "returns [x_scale, y_scale]" do
      scale = font.scale
      expect(scale).to be_an(Array)
      expect(scale.size).to eq(2)
    end

    it "can be set" do
      font.scale = [1000, 1000]
      expect(font.scale).to eq([1000, 1000])
    end
  end

  describe "#ppem" do
    it "returns [x_ppem, y_ppem]" do
      ppem = font.ppem
      expect(ppem).to be_an(Array)
      expect(ppem.size).to eq(2)
    end

    it "can be set" do
      font.ppem = [72, 72]
      expect(font.ppem).to eq([72, 72])
    end
  end

  describe "#ptem" do
    it "returns a float" do
      expect(font.ptem).to be_a(Float)
    end
  end

  describe "#face" do
    it "returns the face" do
      expect(font.face).to be_a(HarfBuzz::Face)
    end
  end

  describe "#glyph" do
    it "returns a glyph codepoint for 'A'" do
      glyph_id = font.glyph(0x41, 0)  # 'A', no variation selector
      expect(glyph_id).to be_an(Integer)
    end
  end

  describe "#glyph_name" do
    it "returns a name for glyph 0" do
      name = font.glyph_name(0)
      expect(name).to be_a(String)
    end
  end

  describe "#glyph_from_name" do
    it "can look up a glyph by name" do
      # Get glyph 0's name first, then look it up by name
      name = font.glyph_name(0)
      glyph_id = font.glyph_from_name(name)
      expect(glyph_id).to be_an(Integer)
    end
  end

  describe "#glyph_advance_for_direction" do
    it "returns [x_advance, y_advance]" do
      adv = font.glyph_advance_for_direction(0, :ltr)
      expect(adv).to be_an(Array)
      expect(adv.size).to eq(2)
    end
  end

  describe "#extents_for_direction" do
    it "returns an HbFontExtentsT struct" do
      extents = font.extents_for_direction(:ltr)
      expect(extents).to be_a(HarfBuzz::C::HbFontExtentsT)
      expect(extents[:ascender]).to be_an(Integer)
      expect(extents[:descender]).to be_an(Integer)
    end
  end

  describe "#make_immutable! / #immutable?" do
    it "can be made immutable" do
      expect(font).not_to be_immutable
      font.make_immutable!
      expect(font).to be_immutable
    end
  end

  describe "#draw_glyph" do
    it "calls draw callbacks for glyph 0" do
      events = []
      draw = HarfBuzz::DrawFuncs.new
      draw.on_move_to    { |x, y| events << [:move_to, x, y] }
      draw.on_line_to    { |x, y| events << [:line_to, x, y] }
      draw.on_quadratic_to { |cx, cy, x, y| events << [:quad, cx, cy, x, y] }
      draw.on_cubic_to   { |c1x, c1y, c2x, c2y, x, y| events << [:cubic, c1x, c1y, c2x, c2y, x, y] }
      draw.on_close_path { events << [:close] }
      font.draw_glyph(0, draw)
      # .notdef glyph may or may not have outlines depending on font
      # We just check that the method doesn't raise
    end
  end
end

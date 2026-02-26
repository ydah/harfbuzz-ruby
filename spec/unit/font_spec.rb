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

  describe ".empty" do
    it "returns the empty Font" do
      expect(described_class.empty).to be_a(described_class)
    end
  end

  describe "#create_sub_font" do
    it "creates a sub-font inheriting from the parent" do
      sub = font.create_sub_font
      expect(sub).to be_a(described_class)
    end
  end

  describe "#nominal_glyph" do
    it "returns a glyph ID for 'A'" do
      glyph = font.nominal_glyph(0x41)
      expect(glyph).to be_an(Integer).or be_nil
    end
  end

  describe "#nominal_glyphs" do
    it "returns an array of glyph IDs" do
      result = font.nominal_glyphs([0x41, 0x42, 0x43])
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      result.each { |g| expect(g).to be_an(Integer) }
    end
  end

  describe "#variation_glyph" do
    it "returns a glyph ID or nil for a codepoint+selector" do
      glyph = font.variation_glyph(0x41, 0xFE0F)
      expect(glyph).to be_an(Integer).or be_nil
    end
  end

  describe "#glyph_h_advance" do
    it "returns an integer advance for glyph 0" do
      expect(font.glyph_h_advance(0)).to be_an(Integer)
    end
  end

  describe "#glyph_v_advance" do
    it "returns an integer advance" do
      expect(font.glyph_v_advance(0)).to be_an(Integer)
    end
  end

  describe "#glyph_h_advances" do
    it "returns an array of advances" do
      result = font.glyph_h_advances([0, 1, 2])
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      result.each { |a| expect(a).to be_an(Integer) }
    end
  end

  describe "#glyph_v_advances" do
    it "returns an array of advances" do
      result = font.glyph_v_advances([0, 1, 2])
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
    end
  end

  describe "#glyph_h_origin" do
    it "returns [x, y] integers" do
      result = font.glyph_h_origin(0)
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end
  end

  describe "#glyph_v_origin" do
    it "returns [x, y] integers" do
      result = font.glyph_v_origin(0)
      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
    end
  end

  describe "#glyph_h_kerning" do
    it "returns an integer kerning value" do
      expect(font.glyph_h_kerning(0, 1)).to be_an(Integer)
    end
  end

  describe "#glyph_extents" do
    it "returns an HbGlyphExtentsT or nil" do
      result = font.glyph_extents(0)
      expect(result).to be_a(HarfBuzz::C::HbGlyphExtentsT).or be_nil
    end
  end

  describe "#glyph_contour_point" do
    it "returns [x, y] or nil" do
      result = font.glyph_contour_point(0, 0)
      expect(result).to be_an(Array).or be_nil
    end
  end

  describe "#inspect" do
    it "includes class name" do
      expect(font.inspect).to include("HarfBuzz::Font")
    end
  end
end

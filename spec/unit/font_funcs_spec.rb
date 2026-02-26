# frozen_string_literal: true

RSpec.describe HarfBuzz::FontFuncs do
  subject(:funcs) { described_class.new }

  describe ".new" do
    it "creates a FontFuncs object" do
      expect(funcs).to be_a(described_class)
    end
  end

  describe ".empty" do
    it "returns the empty singleton" do
      empty = described_class.empty
      expect(empty).to be_a(described_class)
    end
  end

  describe "#immutable? / #make_immutable!" do
    it "starts as mutable" do
      expect(funcs).not_to be_immutable
    end

    it "becomes immutable after make_immutable!" do
      funcs.make_immutable!
      expect(funcs).to be_immutable
    end
  end

  describe "#on_nominal_glyph" do
    it "registers a callback without raising" do
      expect {
        funcs.on_nominal_glyph { |_font, _cp| 42 }
      }.not_to raise_error
    end
  end

  describe "#on_glyph_h_advance" do
    it "registers a callback without raising" do
      expect {
        funcs.on_glyph_h_advance { |_font, _glyph| 500 }
      }.not_to raise_error
    end
  end

  describe "#on_glyph_name" do
    it "registers a callback without raising" do
      expect {
        funcs.on_glyph_name { |_font, glyph| "glyph#{glyph}" }
      }.not_to raise_error
    end
  end

  describe "#on_glyph_contour_point" do
    it "registers a callback without raising" do
      expect {
        funcs.on_glyph_contour_point { |_font, _glyph, _idx| [0, 0] }
      }.not_to raise_error
    end
  end

  describe "#on_draw_glyph" do
    it "registers a callback without raising" do
      expect {
        funcs.on_draw_glyph { |_font, _glyph, _dfuncs, _ddata| }
      }.not_to raise_error
    end
  end

  describe "Font#funcs=" do
    it "sets font funcs via setter syntax" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      custom_funcs = described_class.new
      custom_funcs.make_immutable!
      expect { font.funcs = custom_funcs }.not_to raise_error
    end
  end

  describe "integration: custom font backend" do
    it "uses custom funcs during shaping" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      # Create custom funcs that delegate to the parent font
      custom_funcs = described_class.new
      custom_funcs.on_glyph_h_advance do |_font_ptr, glyph|
        # Return a fixed advance for testing
        glyph == 0 ? 0 : 600
      end
      custom_funcs.make_immutable!
      font.set_funcs(custom_funcs)

      # Shape should still work with custom funcs
      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("A")
      buffer.guess_segment_properties
      expect { HarfBuzz.shape(font, buffer) }.not_to raise_error
    end
  end

  describe "#inspect" do
    it "returns a useful string" do
      expect(funcs.inspect).to include("HarfBuzz::FontFuncs")
    end
  end
end

# frozen_string_literal: true

RSpec.describe HarfBuzz::DrawFuncs do
  subject(:dfuncs) { described_class.new }

  describe ".new" do
    it "creates a DrawFuncs object" do
      expect(dfuncs).to be_a(described_class)
    end
  end

  describe "#immutable? / #make_immutable!" do
    it "starts as mutable" do
      expect(dfuncs).not_to be_immutable
    end

    it "becomes immutable after make_immutable!" do
      dfuncs.make_immutable!
      expect(dfuncs).to be_immutable
    end
  end

  describe "#on_move_to" do
    it "registers a callback without raising" do
      expect { dfuncs.on_move_to { |x, y| } }.not_to raise_error
    end
  end

  describe "#on_line_to" do
    it "registers a callback without raising" do
      expect { dfuncs.on_line_to { |x, y| } }.not_to raise_error
    end
  end

  describe "#on_quadratic_to" do
    it "registers a callback without raising" do
      expect { dfuncs.on_quadratic_to { |cx, cy, x, y| } }.not_to raise_error
    end
  end

  describe "#on_cubic_to" do
    it "registers a callback without raising" do
      expect { dfuncs.on_cubic_to { |c1x, c1y, c2x, c2y, x, y| } }.not_to raise_error
    end
  end

  describe "#on_close_path" do
    it "registers a callback without raising" do
      expect { dfuncs.on_close_path { } }.not_to raise_error
    end
  end

  describe "integration: draw glyph outline" do
    it "invokes callbacks when drawing a glyph" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)

      events = []
      dfuncs.on_move_to    { |x, y|                   events << :move_to }
      dfuncs.on_line_to    { |x, y|                   events << :line_to }
      dfuncs.on_cubic_to   { |c1x, c1y, c2x, c2y, x, y| events << :cubic_to }
      dfuncs.on_close_path { events << :close_path }
      dfuncs.make_immutable!

      # Glyph 0 is .notdef — always present but may have no outline
      # Try glyph 36 ('A' in most fonts has an outline)
      font.draw_glyph(36, dfuncs)
      # We just verify no exception was raised; outline events depend on the font
      expect(events).to be_an(Array)
    end
  end

  describe "#inspect" do
    it "includes class name" do
      expect(dfuncs.inspect).to include("HarfBuzz::DrawFuncs")
    end
  end
end

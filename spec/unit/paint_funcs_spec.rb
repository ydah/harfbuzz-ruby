# frozen_string_literal: true

RSpec.describe HarfBuzz::PaintFuncs do
  subject(:pfuncs) { described_class.new }

  describe ".new" do
    it "creates a PaintFuncs object" do
      expect(pfuncs).to be_a(described_class)
    end
  end

  describe "#immutable? / #make_immutable!" do
    it "starts as mutable" do
      expect(pfuncs).not_to be_immutable
    end

    it "becomes immutable after make_immutable!" do
      pfuncs.make_immutable!
      expect(pfuncs).to be_immutable
    end
  end

  describe "#on_push_transform" do
    it "registers a callback without raising" do
      expect { pfuncs.on_push_transform { |xx, yx, xy, yy, dx, dy| } }.not_to raise_error
    end
  end

  describe "#on_pop_transform" do
    it "registers a callback without raising" do
      expect { pfuncs.on_pop_transform { } }.not_to raise_error
    end
  end

  describe "#on_push_clip_glyph" do
    it "registers a callback without raising" do
      expect { pfuncs.on_push_clip_glyph { |glyph, font| } }.not_to raise_error
    end
  end

  describe "#on_push_clip_rectangle" do
    it "registers a callback without raising" do
      expect { pfuncs.on_push_clip_rectangle { |xmin, ymin, xmax, ymax| } }.not_to raise_error
    end
  end

  describe "#on_pop_clip" do
    it "registers a callback without raising" do
      expect { pfuncs.on_pop_clip { } }.not_to raise_error
    end
  end

  describe "#on_color" do
    it "registers a callback without raising" do
      expect { pfuncs.on_color { |is_foreground, color| } }.not_to raise_error
    end
  end

  describe "#on_push_group" do
    it "registers a callback without raising" do
      expect { pfuncs.on_push_group { } }.not_to raise_error
    end
  end

  describe "#on_pop_group" do
    it "registers a callback without raising" do
      expect { pfuncs.on_pop_group { |mode| } }.not_to raise_error
    end
  end

  describe "#inspect" do
    it "includes class name" do
      expect(pfuncs.inspect).to include("HarfBuzz::PaintFuncs")
    end
  end
end

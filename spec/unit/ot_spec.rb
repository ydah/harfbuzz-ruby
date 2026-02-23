# frozen_string_literal: true

RSpec.describe "HarfBuzz OpenType API" do
  let(:blob)   { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face)   { HarfBuzz::Face.new(blob, 0) }
  let(:font)   { HarfBuzz::Font.new(face) }

  describe HarfBuzz::OT::Layout do
    describe ".script_tags" do
      it "returns an array of tag integers for GSUB" do
        gsub = HarfBuzz.tag("GSUB")
        tags = described_class.script_tags(face, gsub)
        expect(tags).to be_an(Array)
        tags.each { |t| expect(t).to be_an(Integer) }
      end

      it "returns an array for GPOS" do
        gpos = HarfBuzz.tag("GPOS")
        tags = described_class.script_tags(face, gpos)
        expect(tags).to be_an(Array)
      end
    end

    describe ".has_substitution?" do
      it "returns a boolean" do
        result = described_class.has_substitution?(face)
        expect(result).to be(true).or be(false)
      end
    end

    describe ".has_positioning?" do
      it "returns a boolean" do
        result = described_class.has_positioning?(face)
        expect(result).to be(true).or be(false)
      end
    end
  end

  describe HarfBuzz::OT::Metrics do
    # HB_OT_METRICS_TAG_X_HEIGHT = HB_TAG('x','H','g','t')
    let(:x_height_tag) { HarfBuzz.tag("xHgt") }

    describe ".position" do
      it "returns a value or nil for x_height" do
        val = described_class.position(font, x_height_tag)
        expect(val).to be_an(Integer).or be_nil
      end
    end

    describe ".position_with_fallback" do
      it "returns an integer for x_height" do
        val = described_class.position_with_fallback(font, x_height_tag)
        expect(val).to be_an(Integer)
      end
    end
  end

  describe HarfBuzz::OT::Name do
    describe ".list" do
      it "returns an array" do
        names = described_class.list(face)
        expect(names).to be_an(Array)
      end
    end
  end

  describe HarfBuzz::OT::Var do
    describe ".axis_count" do
      it "returns an integer" do
        count = described_class.axis_count(face)
        expect(count).to be_an(Integer)
      end
    end
  end

  describe HarfBuzz::OT::Font do
    describe ".set_funcs" do
      it "does not raise" do
        expect { described_class.set_funcs(font) }.not_to raise_error
      end
    end
  end
end

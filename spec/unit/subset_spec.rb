# frozen_string_literal: true

RSpec.describe HarfBuzz::Subset do
  describe ".available?" do
    it "returns a boolean" do
      result = described_class.available?
      expect(result).to be(true).or be(false)
    end
  end

  context "when available", skip: !HarfBuzz::Subset.available? do
    let(:blob)  { HarfBuzz::Blob.from_file!(system_font_path) }
    let(:face)  { HarfBuzz::Face.new(blob, 0) }

    describe "Input" do
      subject(:input) { described_class::Input.new }

      it "creates an input" do
        expect(input).to be_a(described_class::Input)
      end

      describe "#unicode_set" do
        it "returns a Set" do
          expect(input.unicode_set).to be_a(HarfBuzz::Set)
        end

        it "can add codepoints" do
          input.unicode_set.add(0x41)
          expect(input.unicode_set.include?(0x41)).to be true
        end
      end

      describe "#glyph_set" do
        it "returns a Set" do
          expect(input.glyph_set).to be_a(HarfBuzz::Set)
        end
      end

      describe "#flags" do
        it "returns 0 by default" do
          expect(input.flags).to eq(0)
        end

        it "can be set" do
          input.flags = HarfBuzz::C::SUBSET_FLAGS_NO_HINTING
          expect(input.flags).to eq(HarfBuzz::C::SUBSET_FLAGS_NO_HINTING)
        end
      end
    end

    describe ".subset" do
      it "subsets a font to ASCII" do
        input = described_class::Input.new
        (0x20..0x7E).each { |cp| input.unicode_set.add(cp) }

        subsetted = described_class.subset(face, input)
        expect(subsetted).to be_a(HarfBuzz::Face)
        expect(subsetted.glyph_count).to be > 0
        expect(subsetted.glyph_count).to be < face.glyph_count
      end
    end

    describe "Plan" do
      it "creates and executes a plan" do
        input = described_class::Input.new
        input.unicode_set.add(0x41)

        plan = described_class::Plan.new(face, input)
        expect(plan).to be_a(described_class::Plan)

        subsetted = plan.execute
        expect(subsetted).to be_a(HarfBuzz::Face)
      end

      it "provides glyph mappings" do
        input = described_class::Input.new
        input.unicode_set.add(0x41)
        plan = described_class::Plan.new(face, input)

        expect(plan.old_to_new_glyph_mapping).to be_a(HarfBuzz::Map)
        expect(plan.new_to_old_glyph_mapping).to be_a(HarfBuzz::Map)
        expect(plan.unicode_to_old_glyph_mapping).to be_a(HarfBuzz::Map)
      end
    end
  end
end

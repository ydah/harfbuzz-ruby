# frozen_string_literal: true

RSpec.describe HarfBuzz::Face do
  let(:blob) { HarfBuzz::Blob.from_file!(system_font_path) }

  subject(:face) { described_class.new(blob, 0) }

  describe ".new" do
    it "creates a face" do
      expect(face).to be_a(described_class)
    end

    it "raises for a null blob" do
      empty_blob = HarfBuzz::Blob.empty
      face = described_class.new(empty_blob, 0)
      expect(face).to be_a(described_class)
    end
  end

  describe "#glyph_count" do
    it "returns a positive integer" do
      expect(face.glyph_count).to be > 0
    end
  end

  describe "#upem" do
    it "returns units per em > 0" do
      expect(face.upem).to be > 0
    end
  end

  describe "#index" do
    it "returns 0 for the first face" do
      expect(face.index).to eq(0)
    end
  end

  describe ".count" do
    it "returns a count >= 1" do
      blob2 = HarfBuzz::Blob.from_file!(system_font_path)
      expect(described_class.count(blob2)).to be >= 1
    end
  end

  describe "#table_tags" do
    it "returns an array of integers" do
      tags = face.table_tags
      expect(tags).to be_an(Array)
      expect(tags).not_to be_empty
      tags.each { |t| expect(t).to be_an(Integer) }
    end
  end

  describe "#table / #reference_table" do
    it "returns a Blob for a known table" do
      tags = face.table_tags
      blob = face.table(tags.first)
      expect(blob).to be_a(HarfBuzz::Blob)
    end

    it "reference_table is an alias for table" do
      tags = face.table_tags
      expect(face.reference_table(tags.first)).to be_a(HarfBuzz::Blob)
    end
  end

  describe "#make_immutable! / #immutable?" do
    it "can be made immutable" do
      expect(face).not_to be_immutable
      face.make_immutable!
      expect(face).to be_immutable
    end
  end

  describe "#unicodes" do
    it "returns a Set" do
      expect(face.unicodes).to be_a(HarfBuzz::Set)
    end

    it "contains codepoints" do
      expect(face.unicodes.size).to be > 0
    end
  end

  describe "#nominal_glyph_mapping" do
    it "returns a Map" do
      expect(face.nominal_glyph_mapping).to be_a(HarfBuzz::Map)
    end

    it "contains entries" do
      expect(face.nominal_glyph_mapping.size).to be > 0
    end
  end

  describe "#variation_selectors" do
    it "returns a Set" do
      expect(face.variation_selectors).to be_a(HarfBuzz::Set)
    end
  end

  describe "#variation_unicodes" do
    it "returns a Set for any selector" do
      expect(face.variation_unicodes(0xFE0E)).to be_a(HarfBuzz::Set)
    end
  end
end

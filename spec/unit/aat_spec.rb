# frozen_string_literal: true

RSpec.describe HarfBuzz::AAT::Layout do
  let(:blob)   { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face)   { HarfBuzz::Face.new(blob, 0) }

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

  describe ".has_tracking?" do
    it "returns a boolean" do
      result = described_class.has_tracking?(face)
      expect(result).to be(true).or be(false)
    end
  end

  describe ".feature_types" do
    it "returns an array" do
      result = described_class.feature_types(face)
      expect(result).to be_an(Array)
    end
  end

  describe ".feature_type_name_id" do
    it "returns an integer or nil for type 0" do
      result = described_class.feature_type_name_id(face, 0)
      expect(result).to be_an(Integer).or be_nil
    end
  end

  describe ".selector_infos" do
    it "returns an array for type 0" do
      result = described_class.selector_infos(face, 0)
      expect(result).to be_an(Array)
    end
  end
end

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
end

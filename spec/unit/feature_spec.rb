# frozen_string_literal: true

RSpec.describe HarfBuzz::Feature do
  describe ".from_string" do
    it "parses a feature string" do
      feat = described_class.from_string("kern")
      expect(feat).to be_a(described_class)
    end

    it "parses a feature with value" do
      feat = described_class.from_string("kern=1")
      expect(feat).to be_a(described_class)
    end

    it "parses a disabled feature" do
      feat = described_class.from_string("-kern")
      expect(feat).to be_a(described_class)
    end

    it "raises on invalid input" do
      expect { described_class.from_string("") }.to raise_error(HarfBuzz::FeatureParseError)
    end
  end

  describe ".from_hash" do
    it "converts a hash of features" do
      features = described_class.from_hash(kern: true, liga: false)
      expect(features).to be_an(Array)
      expect(features.size).to eq(2)
      features.each { |f| expect(f).to be_a(described_class) }
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      feat = described_class.from_string("kern")
      expect(feat.to_s).to be_a(String)
      expect(feat.to_s).not_to be_empty
    end
  end

  describe "#to_struct" do
    it "returns an HbFeatureT struct" do
      feat = described_class.from_string("kern")
      struct = feat.to_struct
      expect(struct).to be_a(HarfBuzz::C::HbFeatureT)
    end
  end
end

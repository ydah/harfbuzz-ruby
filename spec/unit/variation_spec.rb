# frozen_string_literal: true

RSpec.describe HarfBuzz::Variation do
  describe ".from_string" do
    it "parses a variation string" do
      var = described_class.from_string("wght=700")
      expect(var).to be_a(described_class)
    end

    it "raises on invalid input" do
      expect { described_class.from_string("") }.to raise_error(HarfBuzz::VariationParseError)
    end
  end

  describe "#to_s" do
    it "returns a string representation" do
      var = described_class.from_string("wght=700")
      expect(var.to_s).to be_a(String)
      expect(var.to_s).not_to be_empty
    end
  end

  describe "#to_struct" do
    it "returns an HbVariationT struct" do
      var = described_class.from_string("wght=700")
      struct = var.to_struct
      expect(struct).to be_a(HarfBuzz::C::HbVariationT)
    end
  end
end

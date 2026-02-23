# frozen_string_literal: true

RSpec.describe HarfBuzz::Flags do
  describe ".to_int" do
    it "converts a single symbol to its integer value" do
      expect(described_class.to_int(:buffer_flags, [:bot])).to eq(0x00000001)
    end

    it "combines multiple symbols with bitwise OR" do
      result = described_class.to_int(:buffer_flags, [:bot, :eot])
      expect(result).to eq(0x00000003)
    end

    it "returns 0 for empty array" do
      expect(described_class.to_int(:buffer_flags, [])).to eq(0)
    end

    it "handles subset_flags" do
      result = described_class.to_int(:subset_flags, [:no_hinting, :retain_gids])
      expect(result).to eq(0x0003)
    end

    it "raises for unknown mapping" do
      expect {
        described_class.to_int(:nonexistent_flags, [:foo])
      }.to raise_error(ArgumentError, /Unknown flag mapping/)
    end

    it "raises for unknown symbol in a valid mapping" do
      expect {
        described_class.to_int(:buffer_flags, [:nonexistent])
      }.to raise_error(ArgumentError, /Unknown flag/)
    end
  end

  describe ".to_symbols" do
    it "converts an integer back to symbols" do
      int = described_class.to_int(:buffer_flags, [:bot, :eot])
      symbols = described_class.to_symbols(:buffer_flags, int)
      expect(symbols).to include(:bot, :eot)
    end

    it "returns empty array for 0" do
      symbols = described_class.to_symbols(:buffer_flags, 0)
      expect(symbols).not_to include(:bot)
    end

    it "raises for unknown mapping" do
      expect {
        described_class.to_symbols(:nonexistent_flags, 0)
      }.to raise_error(ArgumentError, /Unknown flag mapping/)
    end

    it "round-trips glyph_flags" do
      int = described_class.to_int(:glyph_flags, [:unsafe_to_break])
      syms = described_class.to_symbols(:glyph_flags, int)
      expect(syms).to include(:unsafe_to_break)
    end
  end
end

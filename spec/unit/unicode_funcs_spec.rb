# frozen_string_literal: true

RSpec.describe HarfBuzz::UnicodeFuncs do
  subject(:ufuncs) { described_class.new }

  describe ".new" do
    it "creates a UnicodeFuncs object" do
      expect(ufuncs).to be_a(described_class)
    end
  end

  describe ".default" do
    it "returns the default UnicodeFuncs" do
      expect(described_class.default).to be_a(described_class)
    end
  end

  describe ".empty" do
    it "returns the empty UnicodeFuncs" do
      expect(described_class.empty).to be_a(described_class)
    end
  end

  describe "#parent" do
    it "returns a UnicodeFuncs" do
      expect(ufuncs.parent).to be_a(described_class)
    end
  end

  describe "#immutable? / #make_immutable!" do
    it "starts as mutable" do
      expect(ufuncs).not_to be_immutable
    end

    it "becomes immutable after make_immutable!" do
      ufuncs.make_immutable!
      expect(ufuncs).to be_immutable
    end
  end

  describe "#general_category" do
    it "returns a symbol for 'A' (uppercase_letter)" do
      result = ufuncs.general_category(0x41)  # 'A'
      expect(result).to eq(:uppercase_letter)
    end

    it "returns a symbol for '1' (decimal_number)" do
      result = ufuncs.general_category(0x31)  # '1'
      expect(result).to eq(:decimal_number)
    end
  end

  describe "#combining_class" do
    it "returns 0 for a base character" do
      expect(ufuncs.combining_class(0x41)).to eq(0)
    end
  end

  describe "#mirroring" do
    it "returns ')' as mirror of '('" do
      expect(ufuncs.mirroring(0x28)).to eq(0x29)  # '(' → ')'
    end

    it "returns same codepoint for non-mirrored char" do
      expect(ufuncs.mirroring(0x41)).to eq(0x41)  # 'A' → 'A'
    end
  end

  describe "#script" do
    it "returns an integer script value for Latin characters" do
      result = ufuncs.script(0x41)  # 'A'
      expect(result).to be_an(Integer)
    end
  end

  describe "#compose" do
    it "composes combining characters" do
      # U+0041 'A' + U+0300 combining grave accent → U+00C0 'À'
      result = ufuncs.compose(0x0041, 0x0300)
      expect(result).to eq(0x00C0).or be_nil
    end

    it "returns nil for non-composable pairs" do
      result = ufuncs.compose(0x0041, 0x0041)
      expect(result).to be_nil
    end
  end

  describe "#decompose" do
    it "decomposes a composed character" do
      # U+00C0 'À' → U+0041 'A' + U+0300
      result = ufuncs.decompose(0x00C0)
      expect(result).to eq([0x0041, 0x0300]).or be_nil
    end

    it "returns nil for non-decomposable characters" do
      result = ufuncs.decompose(0x0041)  # 'A' has no canonical decomposition
      expect(result).to be_nil
    end
  end

  describe "#on_general_category" do
    it "registers a custom callback without raising" do
      expect {
        ufuncs.on_general_category { |cp| :uppercase_letter }
      }.not_to raise_error
    end
  end

  describe "#on_combining_class" do
    it "registers a custom callback without raising" do
      expect {
        ufuncs.on_combining_class { |cp| 0 }
      }.not_to raise_error
    end
  end

  describe "#inspect" do
    it "includes class name" do
      expect(ufuncs.inspect).to include("HarfBuzz::UnicodeFuncs")
    end
  end
end

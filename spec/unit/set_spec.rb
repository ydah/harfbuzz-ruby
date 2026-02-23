# frozen_string_literal: true

RSpec.describe HarfBuzz::Set do
  subject(:set) { described_class.new }

  describe ".new" do
    it "creates an empty set" do
      expect(set).to be_a(described_class)
      expect(set).to be_empty
    end
  end

  describe "#add / #include?" do
    it "adds a value and checks membership" do
      set.add(65)
      expect(set.include?(65)).to be true
      expect(set.include?(66)).to be false
    end
  end

  describe "#add_range" do
    it "adds a range of values" do
      set.add_range(65, 90)  # A-Z
      expect(set.include?(65)).to be true
      expect(set.include?(90)).to be true
      expect(set.include?(91)).to be false
    end
  end

  describe "#delete" do
    it "removes a value" do
      set.add(65)
      set.delete(65)
      expect(set.include?(65)).to be false
    end
  end

  describe "#size / #length" do
    it "returns the cardinality" do
      set.add(65)
      set.add(66)
      expect(set.size).to eq(2)
    end
  end

  describe "#clear" do
    it "empties the set" do
      set.add(65)
      set.clear
      expect(set).to be_empty
    end
  end

  describe "#to_a" do
    it "converts to a sorted Ruby array" do
      set.add(67)
      set.add(65)
      set.add(66)
      expect(set.to_a).to eq([65, 66, 67])
    end
  end

  describe "set operations" do
    let(:other) { described_class.new }

    before do
      set.add(1)
      set.add(2)
      set.add(3)
      other.add(2)
      other.add(3)
      other.add(4)
    end

    describe "#union" do
      it "returns a new set with all elements" do
        result = set.union(other)
        expect(result.to_a).to eq([1, 2, 3, 4])
        expect(set.to_a).to eq([1, 2, 3])  # original unchanged
      end
    end

    describe "#intersect" do
      it "returns a new set with common elements" do
        result = set.intersect(other)
        expect(result.to_a).to eq([2, 3])
        expect(set.to_a).to eq([1, 2, 3])  # original unchanged
      end
    end

    describe "#subtract" do
      it "returns a new set without elements from other" do
        result = set.subtract(other)
        expect(result.to_a).to eq([1])
        expect(set.to_a).to eq([1, 2, 3])  # original unchanged
      end
    end

    describe "#symmetric_difference" do
      it "returns a new set with elements in exactly one set" do
        result = set.symmetric_difference(other)
        expect(result.to_a).to eq([1, 4])
        expect(set.to_a).to eq([1, 2, 3])  # original unchanged
      end
    end

    describe "#subset?" do
      it "returns true when set is a subset" do
        small = described_class.new
        small.add(2)
        small.add(3)
        expect(small.subset?(set)).to be true
      end

      it "returns false when not a subset" do
        expect(set.subset?(other)).to be false
      end
    end
  end

  describe "#invert!" do
    it "inverts the set (complement)" do
      set.add(0)
      set.invert!
      expect(set.include?(0)).to be false
    end
  end
end

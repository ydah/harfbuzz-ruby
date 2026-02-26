# frozen_string_literal: true

RSpec.describe HarfBuzz::Map do
  subject(:map) { described_class.new }

  describe ".new" do
    it "creates an empty map" do
      expect(map).to be_a(described_class)
      expect(map).to be_empty
    end
  end

  describe "#[]= and #[]" do
    it "stores and retrieves values" do
      map[1] = 100
      expect(map[1]).to eq(100)
    end

    it "returns nil for missing keys" do
      expect(map[999]).to be_nil
    end
  end

  describe "#has_key?" do
    it "returns false for a key not in map" do
      expect(map.has_key?(1)).to be false
    end

    it "returns true after setting a key" do
      map[1] = 100
      expect(map.has_key?(1)).to be true
    end
  end

  describe "#delete" do
    it "removes a key" do
      map[1] = 100
      map.delete(1)
      expect(map.has_key?(1)).to be false
    end
  end

  describe "#size / #length" do
    it "returns 0 for empty map" do
      expect(map.size).to eq(0)
    end

    it "returns count of entries" do
      map[1] = 10
      map[2] = 20
      expect(map.size).to eq(2)
    end
  end

  describe "#clear" do
    it "empties the map" do
      map[1] = 10
      map.clear
      expect(map).to be_empty
    end
  end

  describe "#each" do
    it "iterates over key-value pairs" do
      map[1] = 10
      map[2] = 20
      pairs = []
      map.each { |k, v| pairs << [k, v] }
      expect(pairs).to contain_exactly([1, 10], [2, 20])
    end
  end

  describe "#to_h" do
    it "converts to a Ruby Hash" do
      map[1] = 10
      map[2] = 20
      expect(map.to_h).to eq({ 1 => 10, 2 => 20 })
    end
  end

  describe "#allocation_successful?" do
    it "returns true for a valid map" do
      expect(map.allocation_successful?).to be true
    end
  end

  describe "#keys" do
    it "returns a Set" do
      map[1] = 10
      map[2] = 20
      expect(map.keys).to be_a(HarfBuzz::Set)
    end

    it "contains all keys" do
      map[1] = 10
      map[2] = 20
      keys = map.keys
      expect(keys.include?(1)).to be true
      expect(keys.include?(2)).to be true
    end
  end

  describe "#values" do
    it "returns a Set" do
      map[1] = 10
      expect(map.values).to be_a(HarfBuzz::Set)
    end

    it "contains all values" do
      map[1] = 10
      map[2] = 20
      values = map.values
      expect(values.include?(10)).to be true
      expect(values.include?(20)).to be true
    end
  end
end

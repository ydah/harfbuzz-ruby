# frozen_string_literal: true

RSpec.describe HarfBuzz do
  it "has a version number" do
    expect(HarfBuzz::VERSION).not_to be_nil
  end

  describe ".version" do
    it "returns an array of three integers" do
      result = HarfBuzz.version
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      result.each { |v| expect(v).to be_an(Integer) }
    end
  end

  describe ".version_string" do
    it "returns a version string" do
      result = HarfBuzz.version_string
      expect(result).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe ".version_atleast?" do
    it "returns true for 1.0.0" do
      expect(HarfBuzz.version_atleast?(1, 0, 0)).to be true
    end

    it "returns false for a very high version" do
      expect(HarfBuzz.version_atleast?(999, 0, 0)).to be false
    end
  end

  describe ".tag / .tag_to_s" do
    it "round-trips a 4-character tag" do
      tag_int = HarfBuzz.tag("GSUB")
      expect(HarfBuzz.tag_to_s(tag_int)).to eq("GSUB")
    end
  end

  describe ".direction" do
    it "returns :ltr for 'ltr'" do
      expect(HarfBuzz.direction("ltr")).to eq(:ltr)
    end

    it "returns :rtl for 'rtl'" do
      expect(HarfBuzz.direction("rtl")).to eq(:rtl)
    end
  end

  describe ".language" do
    it "returns a non-null pointer for 'en'" do
      lang = HarfBuzz.language("en")
      expect(lang).not_to be_nil
      expect(lang.null?).to be false
    end
  end

  describe ".default_language" do
    it "returns a pointer" do
      lang = HarfBuzz.default_language
      expect(lang).not_to be_nil
    end
  end

  describe ".shapers" do
    it "returns an array of strings" do
      shapers = HarfBuzz.shapers
      expect(shapers).to be_an(Array)
      expect(shapers).not_to be_empty
      shapers.each { |s| expect(s).to be_a(String) }
    end
  end
end

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

  describe ".version_at_least?" do
    it "is an alias for version_atleast?" do
      expect(HarfBuzz.version_at_least?(1, 0, 0)).to be true
      expect(HarfBuzz.version_at_least?(999, 0, 0)).to be false
    end
  end

  describe ".tag / .tag_to_s" do
    it "round-trips a 4-character tag" do
      tag_int = HarfBuzz.tag("GSUB")
      expect(HarfBuzz.tag_to_s(tag_int)).to eq("GSUB")
    end

    it "accepts an Integer and returns it as-is" do
      tag_int = HarfBuzz.tag("GSUB")
      expect(HarfBuzz.tag(tag_int)).to eq(tag_int)
    end

    it "accepts a Symbol" do
      expect(HarfBuzz.tag(:GSUB)).to eq(HarfBuzz.tag("GSUB"))
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

  describe ".language_to_s" do
    it "returns the BCP 47 string for a language pointer" do
      lang = HarfBuzz.language("en")
      expect(HarfBuzz.language_to_s(lang)).to eq("en")
    end

    it "returns a string for other language tags" do
      lang = HarfBuzz.language("ja")
      expect(HarfBuzz.language_to_s(lang)).to be_a(String)
    end
  end

  describe ".language_matches?" do
    it "returns true for matching language tags" do
      lang1 = HarfBuzz.language("en")
      lang2 = HarfBuzz.language("en")
      expect(HarfBuzz.language_matches?(lang1, lang2)).to be true
    end

    it "returns false for non-matching language tags" do
      lang1 = HarfBuzz.language("en")
      lang2 = HarfBuzz.language("ja")
      expect(HarfBuzz.language_matches?(lang1, lang2)).to be false
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

  describe ".script" do
    it "returns an integer for a known script name" do
      result = HarfBuzz.script("Arab")
      expect(result).to be_an(Integer)
    end

    it "returns the same value as script_from_tag for a matching tag" do
      tag = HarfBuzz.tag("Arab")
      expect(HarfBuzz.script("Arab")).to eq(HarfBuzz.script_from_tag(tag))
    end
  end

  describe ".script_from_tag" do
    it "returns an integer for an ISO 15924 tag" do
      tag = HarfBuzz.tag("Latn")
      result = HarfBuzz.script_from_tag(tag)
      expect(result).to be_an(Integer)
    end
  end

  describe ".color_alpha / .color_red / .color_green / .color_blue" do
    it "extracts alpha" do
      expect(HarfBuzz.color_alpha(0xFF000000)).to be_an(Integer)
    end

    it "extracts red" do
      expect(HarfBuzz.color_red(0xFF0000FF)).to be_an(Integer)
    end

    it "extracts green" do
      expect(HarfBuzz.color_green(0x00FF00FF)).to be_an(Integer)
    end

    it "extracts blue" do
      expect(HarfBuzz.color_blue(0x0000FFFF)).to be_an(Integer)
    end
  end

  describe ".script_horizontal_direction" do
    it "returns :ltr for Latin script" do
      script = HarfBuzz.script("Latn")
      expect(HarfBuzz.script_horizontal_direction(script)).to eq(:ltr)
    end

    it "returns :rtl for Arabic script" do
      script = HarfBuzz.script("Arab")
      expect(HarfBuzz.script_horizontal_direction(script)).to eq(:rtl)
    end
  end
end

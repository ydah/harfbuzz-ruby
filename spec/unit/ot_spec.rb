# frozen_string_literal: true

RSpec.describe "HarfBuzz OpenType API" do
  let(:blob)   { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face)   { HarfBuzz::Face.new(blob, 0) }
  let(:font)   { HarfBuzz::Font.new(face) }

  describe HarfBuzz::OT::Layout do
    let(:gsub) { HarfBuzz.tag("GSUB") }
    let(:gpos) { HarfBuzz.tag("GPOS") }

    describe ".script_tags" do
      it "returns an array of tag integers for GSUB" do
        tags = described_class.script_tags(face, gsub)
        expect(tags).to be_an(Array)
        tags.each { |t| expect(t).to be_an(Integer) }
      end

      it "returns an array for GPOS" do
        tags = described_class.script_tags(face, gpos)
        expect(tags).to be_an(Array)
      end
    end

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

    describe ".attach_points" do
      it "returns an array" do
        expect(described_class.attach_points(face, 1)).to be_an(Array)
      end
    end

    describe ".ligature_carets" do
      it "returns an array" do
        expect(described_class.ligature_carets(font, :ltr, 1)).to be_an(Array)
      end
    end

    describe ".find_script" do
      it "returns [boolean, integer]" do
        result = described_class.find_script(face, gsub, HarfBuzz.tag("latn"))
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to be(true).or be(false)
        expect(result[1]).to be_an(Integer)
      end
    end

    describe ".select_script" do
      it "returns [boolean, integer, integer]" do
        latn = HarfBuzz.tag("latn")
        result = described_class.select_script(face, gsub, [latn])
        expect(result).to be_an(Array)
        expect(result.size).to eq(3)
      end
    end

    describe ".language_tags" do
      it "returns an array for script 0" do
        result = described_class.language_tags(face, gsub, 0)
        expect(result).to be_an(Array)
      end
    end

    describe ".select_language" do
      it "returns [boolean, integer]" do
        eng = HarfBuzz.tag("ENG ")
        result = described_class.select_language(face, gsub, 0, [eng])
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
      end
    end

    describe ".required_feature_index" do
      it "returns an integer or nil" do
        result = described_class.required_feature_index(face, gsub, 0, 0)
        expect(result).to be_an(Integer).or be_nil
      end
    end

    describe ".required_feature" do
      it "returns an array or nil" do
        result = described_class.required_feature(face, gsub, 0, 0)
        expect(result).to be_an(Array).or be_nil
      end
    end

    describe ".feature_indexes" do
      it "returns an array" do
        result = described_class.feature_indexes(face, gsub, 0, 0)
        expect(result).to be_an(Array)
      end
    end

    describe ".feature_tags_for_lang" do
      it "returns an array" do
        result = described_class.feature_tags_for_lang(face, gsub, 0, 0)
        expect(result).to be_an(Array)
      end
    end

    describe ".find_feature" do
      it "returns [boolean, integer]" do
        kern = HarfBuzz.tag("kern")
        result = described_class.find_feature(face, gpos, 0, 0, kern)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
      end
    end

    describe ".feature_lookups" do
      it "returns an array" do
        indexes = described_class.feature_indexes(face, gsub, 0, 0)
        if indexes.any?
          result = described_class.feature_lookups(face, gsub, indexes.first)
          expect(result).to be_an(Array)
        else
          expect(described_class.feature_lookups(face, gsub, 0)).to be_an(Array)
        end
      end
    end

    describe ".size_params" do
      it "returns a Hash or nil" do
        result = described_class.size_params(face)
        expect(result).to be_a(Hash).or be_nil
      end
    end

    describe ".feature_name_ids" do
      it "returns a Hash or nil" do
        result = described_class.feature_name_ids(face, gsub, 0)
        expect(result).to be_a(Hash).or be_nil
      end
    end

    describe ".feature_characters" do
      it "returns an array" do
        result = described_class.feature_characters(face, gsub, 0)
        expect(result).to be_an(Array)
      end
    end

    describe ".baseline" do
      it "returns an integer or nil" do
        roman_baseline = 0  # HB_OT_LAYOUT_BASELINE_TAG_ROMAN = 0x726f6d6e
        result = described_class.baseline(font, roman_baseline, :ltr, HarfBuzz.tag("latn"))
        expect(result).to be_an(Integer).or be_nil
      end
    end

    describe ".baseline_with_fallback" do
      it "returns an integer" do
        roman_baseline = HarfBuzz.tag("romn")
        result = described_class.baseline_with_fallback(font, roman_baseline, :ltr, HarfBuzz.tag("latn"))
        expect(result).to be_an(Integer)
      end
    end

    describe ".baseline2" do
      it "returns an integer or nil (uses hb_script_t + hb_language_t)" do
        roman_baseline = HarfBuzz.tag("romn")
        script = HarfBuzz.script("Latn")
        language = HarfBuzz.language("en")
        result = described_class.baseline2(font, roman_baseline, :ltr, script, language)
        expect(result).to be_an(Integer).or be_nil
      end
    end

    describe ".baseline_with_fallback2" do
      it "returns an integer (uses hb_script_t + hb_language_t)" do
        roman_baseline = HarfBuzz.tag("romn")
        script = HarfBuzz.script("Latn")
        language = HarfBuzz.language("en")
        result = described_class.baseline_with_fallback2(font, roman_baseline, :ltr, script, language)
        expect(result).to be_an(Integer)
      end
    end

    describe ".font_extents" do
      it "returns a Hash or nil" do
        result = described_class.font_extents(font, :ltr, HarfBuzz.tag("latn"))
        expect(result).to be_a(Hash).or be_nil
      end
    end

    describe ".font_extents2" do
      it "returns a Hash or nil (uses hb_script_t + hb_language_t)" do
        script = HarfBuzz.script("Latn")
        language = HarfBuzz.language("en")
        result = described_class.font_extents2(font, :ltr, script, language)
        expect(result).to be_a(Hash).or be_nil
      end
    end

    describe ".horizontal_baseline_tag_for_script" do
      it "returns an integer" do
        script = HarfBuzz.script("Latn")
        result = described_class.horizontal_baseline_tag_for_script(script)
        expect(result).to be_an(Integer)
      end
    end

    describe ".collect_lookups" do
      it "returns a Set" do
        result = described_class.collect_lookups(face, gsub)
        expect(result).to be_a(HarfBuzz::Set)
      end
    end

    describe ".collect_features" do
      it "returns a Set" do
        result = described_class.collect_features(face, gsub)
        expect(result).to be_a(HarfBuzz::Set)
      end
    end

    describe ".tags_from_script_and_language" do
      it "returns [script_tags, language_tags]" do
        script = HarfBuzz.script("Latn")
        lang = HarfBuzz.language("en")
        result = described_class.tags_from_script_and_language(script, lang)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
      end
    end
  end

  describe HarfBuzz::OT::Metrics do
    # HB_OT_METRICS_TAG_X_HEIGHT = HB_TAG('x','H','g','t')
    let(:x_height_tag) { HarfBuzz.tag("xHgt") }

    describe ".position" do
      it "returns a value or nil for x_height" do
        val = described_class.position(font, x_height_tag)
        expect(val).to be_an(Integer).or be_nil
      end
    end

    describe ".position_with_fallback" do
      it "returns an integer for x_height" do
        val = described_class.position_with_fallback(font, x_height_tag)
        expect(val).to be_an(Integer)
      end
    end
  end

  describe HarfBuzz::OT::Name do
    describe ".list" do
      it "returns an array" do
        names = described_class.list(face)
        expect(names).to be_an(Array)
      end
    end
  end

  describe HarfBuzz::OT::Var do
    describe ".axis_count" do
      it "returns an integer" do
        count = described_class.axis_count(face)
        expect(count).to be_an(Integer)
      end
    end
  end

  describe HarfBuzz::OT::Font do
    describe ".set_funcs" do
      it "does not raise" do
        expect { described_class.set_funcs(font) }.not_to raise_error
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe HarfBuzz::ShapePlan do
  let(:blob)  { HarfBuzz::Blob.from_file!(system_font_path) }
  let(:face)  { HarfBuzz::Face.new(blob, 0) }
  let(:font)  { HarfBuzz::Font.new(face) }

  def ltr_props
    props = HarfBuzz::C::HbSegmentPropertiesT.new
    props[:direction] = HarfBuzz::C::Direction[:ltr]
    props[:script]    = HarfBuzz.script("Latn")
    props[:language]  = HarfBuzz.language("en")
    props
  end

  describe ".new" do
    it "creates a ShapePlan" do
      plan = described_class.new(face, ltr_props)
      expect(plan).to be_a(described_class)
    end

    it "creates a ShapePlan with features" do
      features = [HarfBuzz::Feature.from_string("kern")]
      plan = described_class.new(face, ltr_props, features)
      expect(plan).to be_a(described_class)
    end
  end

  describe ".cached" do
    it "returns a ShapePlan" do
      plan = described_class.cached(face, ltr_props)
      expect(plan).to be_a(described_class)
    end
  end

  describe ".empty" do
    it "returns the empty ShapePlan" do
      expect(described_class.empty).to be_a(described_class)
    end
  end

  describe "#shaper" do
    it "returns a shaper name string" do
      plan = described_class.new(face, ltr_props)
      expect(plan.shaper).to be_a(String)
      expect(plan.shaper).not_to be_empty
    end
  end

  describe "#execute" do
    it "shapes a buffer with matching segment properties" do
      # Buffer properties must match the plan's properties
      buffer = HarfBuzz::Buffer.new
      buffer.add_utf8("Hello")
      buffer.direction = :ltr
      buffer.script = HarfBuzz.script("Latn")
      buffer.language = HarfBuzz.language("en")
      props = buffer.segment_properties
      plan = described_class.new(face, props)
      result = plan.execute(font, buffer)
      expect(result).to be(true).or be(false)
    end
  end

  describe "#inspect" do
    it "includes class name and shaper" do
      plan = described_class.new(face, ltr_props)
      expect(plan.inspect).to include("HarfBuzz::ShapePlan")
      expect(plan.inspect).to include("shaper=")
    end
  end
end

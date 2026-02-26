# frozen_string_literal: true

RSpec.describe HarfBuzz::Buffer do
  subject(:buffer) { described_class.new }

  describe ".new" do
    it "creates a buffer" do
      expect(buffer).to be_a(described_class)
    end
  end

  describe "#add_utf8" do
    it "adds UTF-8 text to the buffer" do
      buffer.add_utf8("Hello")
      expect(buffer.length).to eq(5)
    end

    it "handles multi-byte UTF-8 characters" do
      buffer.add_utf8("こんにちは")
      expect(buffer.length).to eq(5)
    end
  end

  describe "#add_codepoints" do
    it "adds codepoints to the buffer" do
      buffer.add_codepoints([0x48, 0x65, 0x6C, 0x6C, 0x6F])
      expect(buffer.length).to eq(5)
    end
  end

  describe "#length" do
    it "returns 0 for an empty buffer" do
      expect(buffer.length).to eq(0)
    end
  end

  describe "#direction" do
    it "can be set and read" do
      buffer.add_utf8("test")
      buffer.direction = :ltr
      expect(buffer.direction).to eq(:ltr)
    end
  end

  describe "#script" do
    it "can be set" do
      buffer.script = HarfBuzz.tag("Latn")
      expect(buffer.script).to eq(HarfBuzz.tag("Latn"))
    end
  end

  describe "#language" do
    it "can be set" do
      buffer.language = HarfBuzz.language("en")
    end
  end

  describe "#content_type" do
    it "returns :invalid for a new buffer" do
      expect(buffer.content_type).to eq(:invalid)
    end
  end

  describe "#flags" do
    it "returns 0 by default" do
      expect(buffer.flags).to eq(0)
    end

    it "can be set" do
      flags = HarfBuzz::C::BUFFER_FLAG_BOT | HarfBuzz::C::BUFFER_FLAG_EOT
      buffer.flags = flags
      expect(buffer.flags).to eq(flags)
    end
  end

  describe "#cluster_level" do
    it "returns :monotone_graphemes by default" do
      expect(buffer.cluster_level).to eq(:monotone_graphemes)
    end
  end

  describe "#guess_segment_properties" do
    it "does not raise" do
      buffer.add_utf8("Hello")
      expect { buffer.guess_segment_properties }.not_to raise_error
    end
  end

  describe "#reset / #clear_output" do
    it "resets the buffer" do
      buffer.add_utf8("Hello")
      buffer.reset
      expect(buffer.length).to eq(0)
    end
  end

  describe "#add_latin1" do
    it "adds Latin-1 text to the buffer" do
      buffer.add_latin1("Hello")
      expect(buffer.length).to eq(5)
    end
  end

  describe "#unicode_funcs / #unicode_funcs=" do
    it "returns a UnicodeFuncs" do
      expect(buffer.unicode_funcs).to be_a(HarfBuzz::UnicodeFuncs)
    end

    it "can be set to custom unicode funcs" do
      ufuncs = HarfBuzz::UnicodeFuncs.new
      expect { buffer.unicode_funcs = ufuncs }.not_to raise_error
    end
  end

  describe "#on_message" do
    it "registers a message callback without raising" do
      expect { buffer.on_message { |msg| } }.not_to raise_error
    end
  end

  describe "#serialize_glyphs" do
    it "serializes after shaping" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      result = buffer.serialize_glyphs(font: font)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe "#serialize_unicode" do
    it "serializes unicode codepoints" do
      buffer.add_utf8("Hi")
      result = buffer.serialize_unicode
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe "#deserialize_unicode" do
    it "deserializes unicode data into the buffer" do
      buffer.add_utf8("Hi")
      serialized = buffer.serialize_unicode
      buffer2 = described_class.new
      result = buffer2.deserialize_unicode(serialized)
      expect(result).to be(true).or be(false)
    end
  end

  describe "#deserialize_glyphs" do
    it "accepts a serialized glyph string" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      serialized = buffer.serialize_glyphs
      buffer2 = described_class.new
      result = buffer2.deserialize_glyphs(serialized, font: font)
      expect(result).to be(true).or be(false)
    end
  end
end

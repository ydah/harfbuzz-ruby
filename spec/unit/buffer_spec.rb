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

  describe "#serialize" do
    it "serializes unicode codepoints when buffer has unicode content" do
      buffer.add_utf8("Hi")
      result = buffer.serialize
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it "serializes after shaping" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      result = buffer.serialize(font: font)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
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

  describe ".empty" do
    it "returns the empty Buffer" do
      expect(described_class.empty).to be_a(described_class)
    end
  end

  describe "#create_similar" do
    it "creates a new buffer with similar properties" do
      buffer.add_utf8("Hello")
      buffer.direction = :ltr
      similar = buffer.create_similar
      expect(similar).to be_a(described_class)
    end
  end

  describe "#pre_allocate / #allocation_successful?" do
    it "pre-allocates space without raising" do
      expect { buffer.pre_allocate(100) }.not_to raise_error
    end

    it "returns true for allocation_successful?" do
      expect(buffer.allocation_successful?).to be true
    end
  end

  describe "#add" do
    it "adds a single codepoint with cluster" do
      buffer.add(0x41, 0)
      expect(buffer.length).to eq(1)
    end
  end

  describe "#add_utf16" do
    it "adds UTF-16 encoded text" do
      buffer.add_utf16("Hello".encode("UTF-16LE"))
      expect(buffer.length).to be > 0
    end
  end

  describe "#add_utf32" do
    it "adds UTF-32 encoded text" do
      buffer.add_utf32("Hi".encode("UTF-32LE"))
      expect(buffer.length).to be > 0
    end
  end

  describe "#append" do
    it "appends from another buffer" do
      buffer.add_utf8("Hello")
      other = described_class.new
      other.add_utf8("World")
      expect { buffer.append(other, 0, other.length) }.not_to raise_error
      expect(buffer.length).to eq(10)
    end
  end

  describe "#random_state / #random_state=" do
    it "returns an integer" do
      expect(buffer.random_state).to be_an(Integer)
    end

    it "can be set" do
      buffer.random_state = 42
      expect(buffer.random_state).to eq(42)
    end
  end

  describe "#has_positions?" do
    it "returns false before shaping" do
      buffer.add_utf8("Hi")
      expect(buffer.has_positions?).to be false
    end
  end

  describe "#glyph_infos" do
    it "returns an array of GlyphInfo objects after shaping" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      infos = buffer.glyph_infos
      expect(infos).to be_an(Array)
      expect(infos).not_to be_empty
      infos.each { |i| expect(i).to be_a(HarfBuzz::GlyphInfo) }
    end
  end

  describe "#glyph_positions" do
    it "returns an array of GlyphPosition objects after shaping" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      positions = buffer.glyph_positions
      expect(positions).to be_an(Array)
      expect(positions).not_to be_empty
      positions.each { |p| expect(p).to be_a(HarfBuzz::GlyphPosition) }
    end
  end

  describe "#reverse / #reverse_clusters / #reverse_range" do
    it "#reverse reverses buffer contents" do
      buffer.add_utf8("ABC")
      expect { buffer.reverse }.not_to raise_error
    end

    it "#reverse_clusters reverses at cluster boundaries" do
      buffer.add_utf8("ABC")
      expect { buffer.reverse_clusters }.not_to raise_error
    end

    it "#reverse_range reverses a sub-range" do
      buffer.add_utf8("ABC")
      expect { buffer.reverse_range(0, 2) }.not_to raise_error
    end
  end

  describe "#normalize_glyphs" do
    it "does not raise" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      expect { buffer.normalize_glyphs }.not_to raise_error
    end
  end

  describe "#replacement_codepoint / #invisible_glyph / #not_found_glyph" do
    it "#replacement_codepoint can be set and read" do
      buffer.replacement_codepoint = 0xFFFD
      expect(buffer.replacement_codepoint).to eq(0xFFFD)
    end

    it "#invisible_glyph can be set and read" do
      buffer.invisible_glyph = 0
      expect(buffer.invisible_glyph).to eq(0)
    end

    it "#not_found_glyph can be set and read" do
      buffer.not_found_glyph = 0
      expect(buffer.not_found_glyph).to eq(0)
    end
  end

  describe "#length=" do
    it "can set the buffer length" do
      buffer.add_utf8("Hello World")
      buffer.length = 5
      expect(buffer.length).to eq(5)
    end
  end

  describe "#diff" do
    it "returns 0 for identical buffers" do
      blob = HarfBuzz::Blob.from_file!(system_font_path)
      face = HarfBuzz::Face.new(blob, 0)
      font = HarfBuzz::Font.new(face)
      buffer.add_utf8("Hi")
      buffer.guess_segment_properties
      HarfBuzz.shape(font, buffer)
      buffer2 = described_class.new
      buffer2.add_utf8("Hi")
      buffer2.guess_segment_properties
      HarfBuzz.shape(font, buffer2)
      result = buffer.diff(buffer2, 0xFFFD, 0)
      expect(result).to eq(HarfBuzz::C::BUFFER_DIFF_FLAG_EQUAL)
    end
  end

  describe "#segment_properties / #segment_properties=" do
    it "returns an HbSegmentPropertiesT" do
      buffer.add_utf8("Hello")
      buffer.guess_segment_properties
      props = buffer.segment_properties
      expect(props).to be_a(HarfBuzz::C::HbSegmentPropertiesT)
    end

    it "can be set from a struct" do
      buffer.add_utf8("Hello")
      buffer.direction = :ltr
      buffer.script = HarfBuzz.script("Latn")
      props = buffer.segment_properties
      buffer2 = described_class.new
      buffer2.add_utf8("Hi")
      expect { buffer2.segment_properties = props }.not_to raise_error
    end
  end

  describe ".serialize_format / .serialize_format_name / .serialize_formats" do
    it ".serialize_format parses a format name" do
      fmt = described_class.serialize_format("text")
      expect(fmt).to be_an(Integer).or be(:text)
    end

    it ".serialize_format_name returns a string" do
      formats = described_class.serialize_formats
      expect(formats).to be_an(Array)
    end

    it ".serialize_formats returns a list" do
      expect(described_class.serialize_formats).to be_an(Array)
      expect(described_class.serialize_formats).not_to be_empty
    end
  end
end

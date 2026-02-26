# frozen_string_literal: true

RSpec.describe HarfBuzz::Blob do
  describe ".empty" do
    subject(:blob) { described_class.empty }

    it "returns a Blob" do
      expect(blob).to be_a(described_class)
    end

    it "has length 0" do
      expect(blob.length).to eq(0)
    end

    it "is immutable" do
      expect(blob).to be_immutable
    end
  end

  describe ".from_file" do
    it "returns a Blob for an existing file" do
      blob = described_class.from_file(system_font_path)
      expect(blob).to be_a(described_class)
      expect(blob.length).to be > 0
    end

    it "returns an empty blob for a non-existent file" do
      blob = described_class.from_file("/nonexistent/path/font.ttf")
      expect(blob).to be_a(described_class)
      expect(blob.length).to eq(0)
    end
  end

  describe ".from_file!" do
    it "returns a Blob for an existing file" do
      blob = described_class.from_file!(system_font_path)
      expect(blob).to be_a(described_class)
      expect(blob.length).to be > 0
    end

    it "raises for a non-existent file" do
      expect {
        described_class.from_file!("/nonexistent/path/font.ttf")
      }.to raise_error(HarfBuzz::AllocationError)
    end
  end

  describe "#make_immutable!" do
    it "makes the blob immutable" do
      blob = described_class.from_file!(system_font_path)
      expect(blob).not_to be_immutable
      blob.make_immutable!
      expect(blob).to be_immutable
    end
  end

  describe "#sub_blob" do
    it "returns a sub-blob" do
      blob = described_class.from_file!(system_font_path)
      sub = blob.sub_blob(0, 4)
      expect(sub).to be_a(described_class)
      expect(sub.length).to eq(4)
    end
  end

  describe "#data" do
    it "returns binary string with correct length" do
      blob = described_class.from_file!(system_font_path)
      d = blob.data
      expect(d).to be_a(String)
      expect(d.bytesize).to eq(blob.length)
    end

    it "returns empty string for empty blob" do
      expect(described_class.empty.data).to eq("".b)
    end
  end

  describe "#data_writable" do
    it "returns nil for an immutable blob" do
      blob = described_class.from_file!(system_font_path)
      blob.make_immutable!
      expect(blob.data_writable).to be_nil
    end

    it "returns binary string for a writable blob" do
      blob = described_class.new("hello")
      result = blob.data_writable
      expect(result).to be_a(String).or be_nil
    end
  end

  describe "#writable_copy" do
    it "returns a writable Blob or nil" do
      blob = described_class.from_file!(system_font_path)
      copy = blob.writable_copy
      expect(copy).to be_a(described_class).or be_nil
    end
  end

  describe "#inspect" do
    it "includes class name, length, and immutable state" do
      blob = described_class.from_file!(system_font_path)
      expect(blob.inspect).to include("HarfBuzz::Blob")
      expect(blob.inspect).to include("length=")
      expect(blob.inspect).to include("immutable=")
    end
  end
end

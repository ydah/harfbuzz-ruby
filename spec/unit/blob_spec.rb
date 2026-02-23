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
end

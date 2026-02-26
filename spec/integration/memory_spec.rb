# frozen_string_literal: true

# Memory leak tests — run with RUN_MEMORY_TESTS=1 bundle exec rspec --tag memory
# Excluded from default CI run (tagged :memory).
RSpec.describe "Memory management", :memory do
  let(:font_path) { system_font_path }

  it "does not leak Buffers over many allocations" do
    GC.start
    before = rss_kb
    5000.times { HarfBuzz::Buffer.new.add_utf8("test") }
    GC.start
    sleep 0.05
    expect(rss_kb - before).to be < 50_000
  end

  it "does not leak Blobs over many open-and-close cycles" do
    GC.start
    before = rss_kb
    500.times { HarfBuzz::Blob.from_file!(font_path) }
    GC.start
    sleep 0.05
    expect(rss_kb - before).to be < 50_000
  end

  it "does not leak when shaping the same text repeatedly" do
    blob = HarfBuzz::Blob.from_file!(font_path)
    face = HarfBuzz::Face.new(blob, 0)
    font = HarfBuzz::Font.new(face)

    GC.start
    before = rss_kb
    1000.times do
      buf = HarfBuzz::Buffer.new
      buf.add_utf8("Hello, World!")
      buf.guess_segment_properties
      HarfBuzz.shape(font, buf)
    end
    GC.start
    sleep 0.05
    expect(rss_kb - before).to be < 50_000
  end
end

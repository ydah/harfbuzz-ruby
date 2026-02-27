# harfbuzz-ruby

Complete Ruby FFI bindings for the [HarfBuzz](https://harfbuzz.github.io/) text shaping engine.

[![CI](https://github.com/ydah/harfbuzz/actions/workflows/main.yml/badge.svg)](https://github.com/ydah/harfbuzz/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/harfbuzz-ruby.svg)](https://badge.fury.io/rb/harfbuzz-ruby)

## Features

- **Complete API coverage** — Core, OpenType Layout, Variable Fonts, Color Fonts, Draw/Paint, AAT, and Subset APIs
- **Two-layer architecture** — Low-level `HarfBuzz::C` (1:1 C binding) + high-level Ruby-idiomatic layer
- **Safe memory management** — `ObjectSpace.define_finalizer` with borrow/own distinction; no manual free needed
- **Thread-safe** — immutable font objects can be shared across threads
- **High-level convenience** — `HarfBuzz.shape_text` shapes text in a single call
- **RBS type signatures** included (`sig/harfbuzz.rbs`)
- **Tested** — 415+ RSpec examples covering all APIs

## Installation

### 1. Install the HarfBuzz C library

**macOS (Homebrew):**
```bash
brew install harfbuzz
```

**Ubuntu / Debian:**
```bash
sudo apt-get install libharfbuzz-dev libharfbuzz-subset0
```

**Fedora / RHEL:**
```bash
sudo dnf install harfbuzz-devel
```

**Alpine:**
```bash
apk add harfbuzz-dev
```

### 2. Add the gem to your Gemfile

```ruby
gem "harfbuzz-ruby"
```

Or install directly:
```bash
gem install harfbuzz-ruby
```

## Quick Start

```ruby
require "harfbuzz"

result = HarfBuzz.shape_text("Hello, World!", font_path: "/path/to/font.ttf")
result.each do |info, pos|
  puts "glyph=#{info.glyph_id} x_advance=#{pos.x_advance}"
end
puts "Total advance: #{result.total_advance.first}"
```

## Basic Usage

### Loading a Font

```ruby
require "harfbuzz"

# Load font data from file
blob = HarfBuzz::Blob.from_file!("/path/to/font.ttf")

# Create a face (font file + face index, 0 for single-face fonts)
face = HarfBuzz::Face.new(blob, 0)
puts "Glyphs: #{face.glyph_count}, upem: #{face.upem}"

# Create a font (metrics, scale, etc.)
font = HarfBuzz::Font.new(face)
```

### Shaping Text

```ruby
# Create a buffer and add text
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("Hello, World!")
buffer.guess_segment_properties  # auto-detect direction/script/language

# Shape!
HarfBuzz.shape(font, buffer)

# Read results
buffer.glyph_infos.zip(buffer.glyph_positions).each do |info, pos|
  puts "glyph_id=#{info.glyph_id} cluster=#{info.cluster} " \
       "x_advance=#{pos.x_advance} x_offset=#{pos.x_offset}"
end
```

### Shaping with Features

```ruby
# Enable ligatures, disable kerning
features = [
  HarfBuzz::Feature.from_string("liga"),    # enable
  HarfBuzz::Feature.from_string("-kern"),   # disable
]
HarfBuzz.shape(font, buffer, features)

# Or use a hash
features = HarfBuzz::Feature.from_hash(liga: true, kern: false, smcp: 2)
HarfBuzz.shape(font, buffer, features)
```

### Buffer Reuse

```ruby
buffer = HarfBuzz::Buffer.new
["Hello", "World", "Ruby"].each do |text|
  buffer.reset          # clears content and properties
  buffer.add_utf8(text)
  buffer.guess_segment_properties
  HarfBuzz.shape(font, buffer)
  puts "#{text}: #{buffer.length} glyphs"
end
```

### RTL / Bidirectional Text

```ruby
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("مرحبا")                # Arabic
buffer.guess_segment_properties         # detects :rtl automatically
puts buffer.direction                   # => :rtl
HarfBuzz.shape(font, buffer)
```

### Setting Direction / Script / Language Explicitly

```ruby
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("Hello")
buffer.direction = :ltr
buffer.script    = HarfBuzz.script("Latn")
buffer.language  = HarfBuzz.language("en")
HarfBuzz.shape(font, buffer)
```

## OpenType Feature Queries

### Listing Scripts and Languages

```ruby
face = HarfBuzz::Face.new(blob, 0)

# List GSUB script tags
scripts = HarfBuzz::OT::Layout.script_tags(face, :gsub)
scripts.each { |tag| puts HarfBuzz.tag_to_s(tag) }

# List language tags for a script
langs = HarfBuzz::OT::Layout.language_tags(face, :gsub, 0)
langs.each { |tag| puts HarfBuzz.tag_to_s(tag) }

# List feature tags for a script+language
features = HarfBuzz::OT::Layout.feature_tags(face, :gsub, 0, 0)
features.each { |tag| puts HarfBuzz.tag_to_s(tag) }
```

### Glyph Classes

```ruby
if HarfBuzz::OT::Layout.has_glyph_classes?(face)
  klass = HarfBuzz::OT::Layout.glyph_class(face, glyph_id)
  puts klass  # => :base, :ligature, :mark, :component
end
```

### OT Metrics

```ruby
puts HarfBuzz::OT::Metrics.x_height(font)
puts HarfBuzz::OT::Metrics.cap_height(font)
puts HarfBuzz::OT::Metrics.ascender(font)
puts HarfBuzz::OT::Metrics.descender(font)
```

### OT Name Table

```ruby
name_ids = (0..255).to_a
name_ids.each do |id|
  str = HarfBuzz::OT::Name.get_utf8(face, id, HarfBuzz.default_language)
  puts "Name #{id}: #{str}" if str
end
```

### Math Table

```ruby
if HarfBuzz::OT::Math.has_data?(face)
  sigma_h = HarfBuzz::OT::Math.constant(font, :math_leading)
  puts "Math leading: #{sigma_h}"
end
```

## Variable Fonts

### Querying Axes

```ruby
face = HarfBuzz::Face.new(blob, 0)

if HarfBuzz::OT::Var.has_data?(face)
  axes = HarfBuzz::OT::Var.axis_infos(face)
  axes.each do |axis|
    puts "#{HarfBuzz.tag_to_s(axis[:tag])}: " \
         "min=#{axis[:min_value]} default=#{axis[:default_value]} max=#{axis[:max_value]}"
  end
end
```

### Setting Variation Axes

```ruby
font = HarfBuzz::Font.new(face)

# Set weight=700 and width=75
variations = [
  HarfBuzz::Variation.from_string("wght=700"),
  HarfBuzz::Variation.from_string("wdth=75"),
]
font.variations = variations

# Or set individual axis
font.set_variation(HarfBuzz.tag("wght"), 700.0)
```

### Named Instances

```ruby
count = HarfBuzz::OT::Var.named_instance_count(face)
count.times do |i|
  coords = HarfBuzz::OT::Var.named_instance_design_coords(face, i)
  puts "Instance #{i}: #{coords.inspect}"
end
```

## Glyph Outline Extraction

```ruby
blob   = HarfBuzz::Blob.from_file!("/path/to/font.ttf")
face   = HarfBuzz::Face.new(blob, 0)
font   = HarfBuzz::Font.new(face)

draw = HarfBuzz::DrawFuncs.new

path_commands = []

draw.on_move_to      { |x, y, _|        path_commands << "M #{x},#{y}" }
draw.on_line_to      { |x, y, _|        path_commands << "L #{x},#{y}" }
draw.on_quadratic_to { |cx, cy, x, y, _| path_commands << "Q #{cx},#{cy} #{x},#{y}" }
draw.on_cubic_to     { |c1x, c1y, c2x, c2y, x, y, _|
                        path_commands << "C #{c1x},#{c1y} #{c2x},#{c2y} #{x},#{y}" }
draw.on_close_path   { |_|              path_commands << "Z" }

draw.make_immutable!

# Draw glyph 36 (typically 'A' in many fonts)
font.draw_glyph(36, draw)
puts path_commands.join(" ")
```

### SVG Path from ShapingResult

```ruby
result = HarfBuzz.shape_text("Hi", font_path: "/path/to/font.ttf")
puts result.to_svg_path
```

## Color Fonts

### Palette Queries

```ruby
if HarfBuzz::OT::Color.has_palettes?(face)
  count = HarfBuzz::OT::Color.palette_count(face)
  puts "#{count} palette(s)"

  colors = HarfBuzz::OT::Color.palette_colors(face, 0)
  colors.each_with_index do |color, i|
    r = HarfBuzz.color_red(color)
    g = HarfBuzz.color_green(color)
    b = HarfBuzz.color_blue(color)
    a = HarfBuzz.color_alpha(color)
    puts "Color #{i}: rgba(#{r}, #{g}, #{b}, #{a})"
  end
end
```

### COLR v1 Paint

```ruby
if HarfBuzz::OT::Color.has_paint?(face)
  paint = HarfBuzz::PaintFuncs.new
  # Set up callbacks...
  font.paint_glyph(glyph_id, paint)
end
```

## Font Subsetting

Requires `libharfbuzz-subset` (usually included with the main library):

```ruby
unless HarfBuzz::Subset.available?
  raise "libharfbuzz-subset not found"
end

blob = HarfBuzz::Blob.from_file!("/path/to/font.ttf")
face = HarfBuzz::Face.new(blob, 0)

input = HarfBuzz::Subset::Input.new

# Add codepoints to keep
unicode_set = input.unicode_set
"Hello".each_codepoint { |cp| unicode_set.add(cp) }

# Subset the font
subsetted_face = HarfBuzz::Subset.subset(face, input)
puts "Subsetted glyph count: #{subsetted_face.glyph_count}"
```

## Low-Level API

Access C functions directly via `HarfBuzz::C`:

```ruby
# Direct C function call
ptr = HarfBuzz::C.hb_buffer_create
HarfBuzz::C.hb_buffer_add_utf8(ptr, "Hello", 5, 0, -1)
HarfBuzz::C.hb_buffer_destroy(ptr)

# Custom library path
HarfBuzz.library_path = "/opt/custom/lib/libharfbuzz.dylib"
require "harfbuzz"
```

## Thread Safety

HarfBuzz is thread-safe for **immutable** objects. The recommended pattern for concurrent shaping:

```ruby
# Create and freeze shared objects once
blob = HarfBuzz::Blob.from_file!("font.ttf")
face = HarfBuzz::Face.new(blob, 0)
face.make_immutable!
font = HarfBuzz::Font.new(face)
font.make_immutable!

# Each thread gets its own buffer
threads = 4.times.map do |i|
  Thread.new do
    buffer = HarfBuzz::Buffer.new  # buffers are NOT shared
    buffer.add_utf8("Hello #{i}")
    buffer.guess_segment_properties
    HarfBuzz.shape(font, buffer)   # font IS shared safely
    buffer.glyph_infos
  end
end

results = threads.map(&:value)
```

**Rules:**
- `Blob`, `Face`, `Font` — safe to share after `make_immutable!`
- `Buffer` — **never** share across threads; create one per thread
- `DrawFuncs`, `PaintFuncs` — safe to share after `make_immutable!`

## Troubleshooting

### `FFI::NotFoundError: libharfbuzz not found`

The HarfBuzz shared library cannot be located. Solutions:
1. Install the library (see [Installation](#installation))
2. Set `HARFBUZZ_LIB_PATH` environment variable:
   ```bash
   HARFBUZZ_LIB_PATH=/custom/path/libharfbuzz.dylib ruby my_script.rb
   ```
3. Set the path in code before requiring:
   ```ruby
   require "harfbuzz/library"
   HarfBuzz.library_path = "/custom/path/libharfbuzz.dylib"
   require "harfbuzz"
   ```

### `HarfBuzz::AllocationError: Failed to create blob from file`

- Check the file path is correct and readable
- Use `Blob.from_file` (returns empty blob on failure) instead of `Blob.from_file!` if you want to handle errors gracefully

### Subset API unavailable

```ruby
puts HarfBuzz::Subset.available?  # => false
```

Install `libharfbuzz-subset`:
- Ubuntu: `sudo apt-get install libharfbuzz-subset0`
- macOS: included with `brew install harfbuzz`

### Glyph outlines are empty

Some fonts do not include TrueType/CFF outlines (e.g., bitmap-only or SVG fonts). Check `font.draw_glyph` returns any commands.

## API Reference

Generated API docs are available via YARD:

```bash
bundle exec yard doc
bundle exec yard server
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ydah/harfbuzz.

1. Fork the repository
2. Create a feature branch (`git checkout -b my-feature`)
3. Write tests for your changes
4. Run the test suite: `bundle exec rspec`
5. Run RuboCop: `bundle exec rubocop`
6. Submit a pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

HarfBuzz itself is also MIT-licensed. See [HarfBuzz license](https://github.com/harfbuzz/harfbuzz/blob/main/COPYING).

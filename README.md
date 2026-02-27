# HarfBuzz Ruby

Ruby bindings for [HarfBuzz](https://harfbuzz.github.io/) text shaping engine.

## Features

- Complete HarfBuzz API bindings using Ruby-FFI
- Two-layer architecture: low-level `HarfBuzz::C` (1:1 C binding) + high-level Ruby-idiomatic layer
- Safe memory management with borrow/own distinction
- Thread-safe immutable font objects
- Cross-platform support (macOS, Linux)
- RBS type signatures included

## Requirements

- Ruby 3.1+
- HarfBuzz C library installed on your system
- Supported platforms:
  - macOS (Homebrew)
  - Ubuntu / Debian
  - Fedora / RHEL
  - Alpine

## Installation

Install the HarfBuzz C library:

```bash
# macOS
brew install harfbuzz

# Ubuntu / Debian
sudo apt-get install libharfbuzz-dev libharfbuzz-subset0

# Fedora / RHEL
sudo dnf install harfbuzz-devel

# Alpine
apk add harfbuzz-dev
```

Add to your Gemfile:

```ruby
gem 'harfbuzz-ruby'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install harfbuzz-ruby
```

### Custom Library Path

To use a custom build of HarfBuzz:

```bash
export HARFBUZZ_LIB_PATH=/path/to/libharfbuzz.dylib
```

## Usage

### Basic Setup

```ruby
require "harfbuzz"

result = HarfBuzz.shape_text("Hello, World!", font_path: "/path/to/font.ttf")
result.each do |info, pos|
  puts "glyph=#{info.glyph_id} x_advance=#{pos.x_advance}"
end
puts "Total advance: #{result.total_advance.first}"
```

### Text Shaping Example

```ruby
require "harfbuzz"

# Load font
blob = HarfBuzz::Blob.from_file!("/path/to/font.ttf")
face = HarfBuzz::Face.new(blob, 0)
font = HarfBuzz::Font.new(face)

# Create buffer and add text
buffer = HarfBuzz::Buffer.new
buffer.add_utf8("Hello, World!")
buffer.guess_segment_properties

# Shape
HarfBuzz.shape(font, buffer)

# Read results
buffer.glyph_infos.zip(buffer.glyph_positions).each do |info, pos|
  puts "glyph_id=#{info.glyph_id} cluster=#{info.cluster} " \
       "x_advance=#{pos.x_advance} x_offset=#{pos.x_offset}"
end
```

### Shaping with Features

```ruby
features = [
  HarfBuzz::Feature.from_string("liga"),    # enable ligatures
  HarfBuzz::Feature.from_string("-kern"),   # disable kerning
]
HarfBuzz.shape(font, buffer, features)

# Or use a hash
features = HarfBuzz::Feature.from_hash(liga: true, kern: false, smcp: 2)
HarfBuzz.shape(font, buffer, features)
```

### Variable Fonts

```ruby
font = HarfBuzz::Font.new(face)

# Set weight=700 and width=75
variations = [
  HarfBuzz::Variation.from_string("wght=700"),
  HarfBuzz::Variation.from_string("wdth=75"),
]
font.variations = variations
```

### Glyph Outline Extraction

```ruby
draw = HarfBuzz::DrawFuncs.new

path_commands = []
draw.on_move_to      { |x, y, _|        path_commands << "M #{x},#{y}" }
draw.on_line_to      { |x, y, _|        path_commands << "L #{x},#{y}" }
draw.on_quadratic_to { |cx, cy, x, y, _| path_commands << "Q #{cx},#{cy} #{x},#{y}" }
draw.on_cubic_to     { |c1x, c1y, c2x, c2y, x, y, _|
                        path_commands << "C #{c1x},#{c1y} #{c2x},#{c2y} #{x},#{y}" }
draw.on_close_path   { |_|              path_commands << "Z" }
draw.make_immutable!

font.draw_glyph(36, draw)
puts path_commands.join(" ")
```

### Font Subsetting

```ruby
input = HarfBuzz::Subset::Input.new

unicode_set = input.unicode_set
"Hello".each_codepoint { |cp| unicode_set.add(cp) }

subsetted_face = HarfBuzz::Subset.subset(face, input)
puts "Subsetted glyph count: #{subsetted_face.glyph_count}"
```

## Examples

See the `examples/` directory for more complete examples:

- `basic_shaping.rb` - Basic text shaping
- `glyph_outlines.rb` - Glyph outline extraction
- `opentype_features.rb` - OpenType feature queries
- `variable_fonts.rb` - Variable font axis manipulation
- `render_svg.rb` - Render shaped text to SVG and open in browser
- `render_waterfall.rb` - Variable font weight waterfall (HTML + SVG)

Run an example:

```bash
bundle exec ruby examples/basic_shaping.rb
```

Rendering examples generate SVG/HTML and open them in the default browser:

```bash
bundle exec ruby examples/render_svg.rb "Hello, HarfBuzz!"
bundle exec ruby examples/render_waterfall.rb /path/to/variable_font.ttf
```

## API Overview

### Core Objects

| Class | Description |
|-------|-------------|
| `HarfBuzz::Blob` | Binary data container for font files |
| `HarfBuzz::Face` | Font face (typeface + index) |
| `HarfBuzz::Font` | Font instance with metrics and scale |
| `HarfBuzz::Buffer` | Text buffer for shaping input/output |

### Shaping

| Class | Description |
|-------|-------------|
| `HarfBuzz::Feature` | OpenType feature toggle |
| `HarfBuzz::Variation` | Variable font axis setting |
| `HarfBuzz::ShapePlan` | Reusable shaping plan |
| `HarfBuzz::ShapingResult` | Shaped text result with glyph info |
| `HarfBuzz::GlyphInfo` | Glyph ID and cluster info |
| `HarfBuzz::GlyphPosition` | Glyph advance and offset |

### Drawing & Color

| Class | Description |
|-------|-------------|
| `HarfBuzz::DrawFuncs` | Glyph outline extraction callbacks |
| `HarfBuzz::PaintFuncs` | Color font paint callbacks |

### OpenType

| Class | Description |
|-------|-------------|
| `HarfBuzz::OT::Layout` | GSUB/GPOS script, language, and feature queries |
| `HarfBuzz::OT::Var` | Variable font axis and instance queries |
| `HarfBuzz::OT::Metrics` | Font metrics (x-height, cap-height, etc.) |
| `HarfBuzz::OT::Name` | Name table access |
| `HarfBuzz::OT::Color` | Color palette and COLR queries |
| `HarfBuzz::OT::Math` | Math table queries |
| `HarfBuzz::OT::Meta` | Metadata queries |

### Subsetting

| Class | Description |
|-------|-------------|
| `HarfBuzz::Subset` | Font subsetting API |
| `HarfBuzz::Set` | Integer set for codepoints/glyphs |
| `HarfBuzz::Map` | Integer-to-integer mapping |

## Development

```bash
git clone https://github.com/ydah/harfbuzz.git
cd harfbuzz
bundle install
bundle exec rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ydah/harfbuzz.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## References

- [HarfBuzz Documentation](https://harfbuzz.github.io/)
- [HarfBuzz GitHub](https://github.com/harfbuzz/harfbuzz)
- [OpenType Specification](https://learn.microsoft.com/en-us/typography/opentype/spec/)

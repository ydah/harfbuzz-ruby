# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-02-27

### Added

#### Core API
- `HarfBuzz::Blob` — load font data from file or memory with `from_file!`, `from_data`, `from_data!`
- `HarfBuzz::Buffer` — full text buffer API: `add_utf8`, `add_utf16`, `add_utf32`, `add_latin1`, `add_codepoints`, `guess_segment_properties`, `serialize`/`deserialize`, `diff`
- `HarfBuzz::Face` — font face wrapper with `for_tables`, `glyph_count`, `upem`, `collect_unicodes`, `collect_variation_selectors`
- `HarfBuzz::Font` — font metrics, glyph extents, draw/paint glyph, synthetic bold/slant, variable font axis coordination
- `HarfBuzz::Map` — associative map with `[]`, `[]=`, `each`, `to_h`, `merge`, `replace`
- `HarfBuzz::Set` — codepoint set with `add`, `del`, `has?`, `each`, `each_range`, `reverse_each`, `union`, `intersect`, `subtract`
- `HarfBuzz::Feature` — OpenType feature with `from_string`, `to_s`, `from_hash`
- `HarfBuzz::Variation` — variable font variation axis with `from_string`, `to_s`
- `HarfBuzz::DrawFuncs` — glyph outline extraction callbacks (`on_move_to`, `on_line_to`, `on_quadratic_to`, `on_cubic_to`, `on_close_path`)
- `HarfBuzz::PaintFuncs` — color glyph paint callbacks
- `HarfBuzz::FontFuncs` — custom font function overrides
- `HarfBuzz::UnicodeFuncs` — Unicode property function overrides
- `HarfBuzz::ShapePlan` — reusable shaping plan
- `HarfBuzz::GlyphInfo` — glyph ID and cluster info after shaping
- `HarfBuzz::GlyphPosition` — x/y advance and offset after shaping
- `HarfBuzz::ShapingResult` — high-level shaping result with `Enumerable`, `total_advance`

#### High-level Convenience API
- `HarfBuzz.shape(font, buffer, features, shapers:)` — shape text with optional features
- `HarfBuzz.shape_text(text, font_path:, features:, direction:, script:, language:)` — one-line shaping
- `HarfBuzz.shapers` — list available shaping engines
- `HarfBuzz.tag` / `HarfBuzz.tag_to_s` — OpenType tag conversion
- `HarfBuzz.language` / `HarfBuzz.language_to_s` / `HarfBuzz.language_matches?` — language handling
- `HarfBuzz.direction` / `HarfBuzz.script` / `HarfBuzz.script_from_tag` / `HarfBuzz.script_horizontal_direction`
- `HarfBuzz.color_alpha` / `color_red` / `color_green` / `color_blue` — RGBA color component extraction
- `HarfBuzz.version` / `version_string` / `version_atleast?`

#### OpenType API (`HarfBuzz::OT`)
- `OT::Layout` — GSUB/GPOS script/language/feature/lookup queries, glyph class queries, `tags_to_script_and_language`, `glyphs_in_class`
- `OT::Color` — palette enumeration, layer queries, SVG/PNG/CPAL color data, COLR v1 paint support
- `OT::Math` — math constant queries, math glyph variants and assemblies
- `OT::Meta` — metadata tag listing and entry retrieval
- `OT::Metrics` — font metric queries (x-height, cap-height, etc.) with variation support
- `OT::Name` — name table queries (`get_utf8`, `get_utf16`, `get_utf32`)
- `OT::Shape` — `glyphs_closure`, `plan_collect_lookups`
- `OT::Var` — variable font axis info, named instances, normalization
- `OT::Font` — OT-level font creation

#### AAT API (`HarfBuzz::AAT`)
- `AAT::Layout` — Apple Advanced Typography feature enumeration

#### Subset API (`HarfBuzz::Subset`)
- `Subset::Input` — input configuration for subsetting
- `Subset.subset!` — create font subset

#### Memory management
- Two-pattern memory model: `wrap_owned` (with GC finalizer) vs `wrap_borrowed` (no finalizer)
- Thread-safe via HarfBuzz's internal immutability guarantees; `make_immutable!` for shared objects

#### Require aliases
- `require "harfbuzz"` — primary entry point
- `require "harfbuzz-ffi"` — compatibility alias

[Unreleased]: https://github.com/ydah/harfbuzz/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ydah/harfbuzz/releases/tag/v1.0.0

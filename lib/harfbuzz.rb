# frozen_string_literal: true

require_relative "harfbuzz/version"
require_relative "harfbuzz/error"
require_relative "harfbuzz/library"

# Load FFI low-level layer
require_relative "harfbuzz/c/base"
require_relative "harfbuzz/c/enums"
require_relative "harfbuzz/c/structs"
require_relative "harfbuzz/c/version"
require_relative "harfbuzz/c/common"
require_relative "harfbuzz/c/blob"
require_relative "harfbuzz/c/buffer"
require_relative "harfbuzz/c/face"
require_relative "harfbuzz/c/font"
require_relative "harfbuzz/c/shape"
require_relative "harfbuzz/c/map"
require_relative "harfbuzz/c/set"
require_relative "harfbuzz/c/shape_plan"
require_relative "harfbuzz/c/unicode"
require_relative "harfbuzz/c/draw"
require_relative "harfbuzz/c/paint"
require_relative "harfbuzz/c/ot/layout"
require_relative "harfbuzz/c/ot/var"
require_relative "harfbuzz/c/ot/color"
require_relative "harfbuzz/c/ot/math"
require_relative "harfbuzz/c/ot/meta"
require_relative "harfbuzz/c/ot/metrics"
require_relative "harfbuzz/c/ot/name"
require_relative "harfbuzz/c/ot/shape"
require_relative "harfbuzz/c/ot/font"
require_relative "harfbuzz/c/aat/layout"

# Load high-level Ruby layer
require_relative "harfbuzz/glyph_info"
require_relative "harfbuzz/glyph_position"
require_relative "harfbuzz/feature"
require_relative "harfbuzz/variation"
require_relative "harfbuzz/blob"
require_relative "harfbuzz/buffer"
require_relative "harfbuzz/face"
require_relative "harfbuzz/font"
require_relative "harfbuzz/map"
require_relative "harfbuzz/set"
require_relative "harfbuzz/shape_plan"
require_relative "harfbuzz/unicode_funcs"
require_relative "harfbuzz/draw_funcs"
require_relative "harfbuzz/paint_funcs"
require_relative "harfbuzz/shaping_result"

# OT namespace
module HarfBuzz
  module OT; end
end
require_relative "harfbuzz/ot/layout"
require_relative "harfbuzz/ot/var"
require_relative "harfbuzz/ot/color"
require_relative "harfbuzz/ot/math"
require_relative "harfbuzz/ot/meta"
require_relative "harfbuzz/ot/metrics"
require_relative "harfbuzz/ot/name"
require_relative "harfbuzz/ot/shape"
require_relative "harfbuzz/ot/font"

# AAT namespace
module HarfBuzz
  module AAT; end
end
require_relative "harfbuzz/aat/layout"

# Subset (loads libharfbuzz-subset if available)
require_relative "harfbuzz/c/subset"
require_relative "harfbuzz/subset"

# HarfBuzz Ruby FFI Bindings
#
# This module provides complete Ruby bindings for the HarfBuzz text shaping engine.
# It uses FFI to provide both low-level C API access (HarfBuzz::C) and high-level
# Ruby-friendly interfaces.
#
# @example Basic shaping
#   blob = HarfBuzz::Blob.from_file!("font.ttf")
#   face = HarfBuzz::Face.new(blob, 0)
#   font = HarfBuzz::Font.new(face)
#   buffer = HarfBuzz::Buffer.new
#   buffer.add_utf8("Hello")
#   buffer.guess_segment_properties
#   HarfBuzz.shape(font, buffer)
module HarfBuzz
  # Returns the HarfBuzz library version as an array [major, minor, micro]
  # @return [Array<Integer>] Version array
  def self.version
    major_ptr = FFI::MemoryPointer.new(:uint)
    minor_ptr = FFI::MemoryPointer.new(:uint)
    micro_ptr = FFI::MemoryPointer.new(:uint)

    C.hb_version(major_ptr, minor_ptr, micro_ptr)

    [major_ptr.read_uint, minor_ptr.read_uint, micro_ptr.read_uint]
  end

  # Returns the HarfBuzz library version as a string
  # @return [String] Version string (e.g., "8.3.0")
  def self.version_string
    C.hb_version_string
  end

  # Checks if the library version is at least the specified version
  # @param major [Integer] Major version
  # @param minor [Integer] Minor version
  # @param micro [Integer] Micro version
  # @return [Boolean] true if version >= specified
  def self.version_atleast?(major, minor, micro)
    C.from_hb_bool(C.hb_version_atleast(major, minor, micro))
  end

  # Converts a 4-character string to an OpenType tag (uint32)
  # @param str [String] 4-character tag string (e.g., "GSUB")
  # @return [Integer] Tag as uint32
  def self.tag(str)
    C.hb_tag_from_string(str, str.bytesize)
  end

  # Converts an OpenType tag (uint32) to a 4-character string
  # @param tag [Integer] Tag as uint32
  # @return [String] 4-character tag string
  def self.tag_to_s(tag)
    buf = FFI::MemoryPointer.new(:char, 4)
    C.hb_tag_to_string(tag, buf)
    buf.read_bytes(4)
  end

  # Converts a direction string to a direction enum value
  # @param str [String] Direction string (e.g., "ltr")
  # @return [Symbol] Direction symbol
  def self.direction(str)
    C.hb_direction_from_string(str, str.bytesize)
  end

  # Returns a language opaque pointer from a BCP 47 language tag string
  # @param str [String] BCP 47 language tag (e.g., "en", "ar")
  # @return [FFI::Pointer] Language pointer
  def self.language(str)
    C.hb_language_from_string(str, str.bytesize)
  end

  # Returns the default language
  # @return [FFI::Pointer] Default language pointer
  def self.default_language
    C.hb_language_get_default
  end

  # Returns the horizontal direction for a script
  # @param script [Integer] Script value
  # @return [Symbol] Direction symbol (:ltr or :rtl)
  def self.script_horizontal_direction(script)
    C.hb_script_get_horizontal_direction(script)
  end

  # Shapes text in the buffer using the font
  # @param font [Font] Font to use for shaping
  # @param buffer [Buffer] Buffer containing text to shape
  # @param features [Array<Feature>] Optional features to apply
  # @param shapers [Array<String>, nil] Optional list of shapers to try
  def self.shape(font, buffer, features = [], shapers: nil)
    features_ptr = build_features_ptr(features)

    if shapers
      shapers_ptrs = shapers.map { |s| FFI::MemoryPointer.from_string(s) }
      shapers_ptrs << FFI::Pointer::NULL
      shapers_ptr = FFI::MemoryPointer.new(:pointer, shapers_ptrs.size)
      shapers_ptrs.each_with_index { |p, i| shapers_ptr[i].put_pointer(0, p) }
      C.hb_shape_full(font.ptr, buffer.ptr, features_ptr, features.size, shapers_ptr)
    else
      C.hb_shape(font.ptr, buffer.ptr, features_ptr, features.size)
    end
  end

  # Returns the list of available shapers
  # @return [Array<String>] List of shaper names
  def self.shapers
    ptr = C.hb_shape_list_shapers
    result = []
    i = 0
    loop do
      p = ptr.get_pointer(i * FFI::Pointer.size)
      break if p.null?

      result << p.read_string
      i += 1
    end
    result
  end

  # High-level shaping convenience method
  #
  # @param text [String] Text to shape
  # @param font_path [String] Path to font file
  # @param features [Array<Feature, String>, Hash] Features to apply
  # @param direction [Symbol, nil] Text direction (:ltr, :rtl, etc.)
  # @param script [Integer, nil] Script value
  # @param language [String, nil] BCP 47 language tag (e.g., "en")
  # @return [ShapingResult]
  def self.shape_text(text, font_path:, features: [], direction: nil, script: nil, language: nil)
    blob = Blob.from_file!(font_path)
    face = Face.new(blob, 0)
    font = Font.new(face)

    buffer = Buffer.new
    buffer.add_utf8(text)
    buffer.direction = direction if direction
    buffer.script = script if script
    buffer.language = self.language(language) if language
    buffer.guess_segment_properties

    parsed_features = case features
                      when Array
                        features.map { |f| f.is_a?(Feature) ? f : Feature.from_string(f.to_s) }
                      when Hash
                        Feature.from_hash(features)
                      else
                        []
                      end

    shape(font, buffer, parsed_features)
    ShapingResult.new(buffer: buffer, font: font)
  end

  def self.build_features_ptr(features)
    return FFI::Pointer::NULL if features.empty?

    ptr = FFI::MemoryPointer.new(C::HbFeatureT, features.size)
    features.each_with_index do |f, i|
      s = f.to_struct
      ptr.put_bytes(i * C::HbFeatureT.size, s.to_ptr.read_bytes(C::HbFeatureT.size))
    end
    ptr
  end
  private_class_method :build_features_ptr
end

# Alias for compatibility
Harfbuzz = HarfBuzz

# frozen_string_literal: true

require "ffi"

module HarfBuzz
  # Low-level FFI bindings to HarfBuzz C API
  module C
    extend FFI::Library

    # Load the HarfBuzz shared library
    ffi_lib HarfBuzz.library_path

    # === Basic Types ===
    # hb_bool_t is int in C
    typedef :int, :hb_bool_t

    # Codepoint (Unicode code point)
    typedef :uint32, :hb_codepoint_t

    # Position value (signed 26.6 fixed point or font units)
    typedef :int32, :hb_position_t

    # Bitmask
    typedef :uint32, :hb_mask_t

    # OpenType tag (4-byte identifier)
    typedef :uint32, :hb_tag_t

    # Color value (RGBA)
    typedef :uint32, :hb_color_t

    # OpenType name ID
    typedef :uint, :hb_ot_name_id_t

    # === Opaque Pointer Types ===
    # Each opaque pointer type is typedef'd for semantic clarity

    # Blob (binary data)
    typedef :pointer, :hb_blob_t

    # Buffer (text buffer for shaping)
    typedef :pointer, :hb_buffer_t

    # Face (font face)
    typedef :pointer, :hb_face_t

    # Font (sized font instance)
    typedef :pointer, :hb_font_t

    # Font functions table
    typedef :pointer, :hb_font_funcs_t

    # Unicode functions table
    typedef :pointer, :hb_unicode_funcs_t

    # Draw functions table
    typedef :pointer, :hb_draw_funcs_t

    # Paint functions table
    typedef :pointer, :hb_paint_funcs_t

    # Map (integer to integer mapping)
    typedef :pointer, :hb_map_t

    # Set (integer set)
    typedef :pointer, :hb_set_t

    # Shape plan (cached shaping plan)
    typedef :pointer, :hb_shape_plan_t

    # Subset input
    typedef :pointer, :hb_subset_input_t

    # Subset plan
    typedef :pointer, :hb_subset_plan_t

    # === Helper Methods ===

    # Converts Ruby boolean to hb_bool_t (int)
    # @param value [Boolean] Ruby boolean
    # @return [Integer] 1 for true, 0 for false
    def self.to_hb_bool(value)
      value ? 1 : 0
    end

    # Converts hb_bool_t (int) to Ruby boolean
    # @param value [Integer] HarfBuzz boolean (0 or non-zero)
    # @return [Boolean] Ruby boolean
    def self.from_hb_bool(value)
      !value.zero?
    end

    # Converts a 4-character tag string to hb_tag_t (uint32)
    # @param tag [String] 4-character tag (e.g., "GSUB")
    # @return [Integer] Tag as uint32
    def self.tag_from_string(tag)
      raise ArgumentError, "Tag must be a String" unless tag.is_a?(String)

      # Pad or truncate to 4 bytes
      bytes = tag.bytes.take(4)
      bytes += [0x20] * (4 - bytes.size) if bytes.size < 4

      # Pack as big-endian uint32
      bytes.pack("C4").unpack1("N")
    end

    # Converts hb_tag_t (uint32) to 4-character string
    # @param tag [Integer] Tag as uint32
    # @return [String] 4-character tag string
    def self.tag_to_string(tag)
      [tag].pack("N").unpack("C4").pack("C*")
    end
  end
end

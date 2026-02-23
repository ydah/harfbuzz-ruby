# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Math Typesetting API
    module Math
      module_function

      # @param face [Face] Font face
      # @return [Boolean] true if the face has a MATH table
      def has_data?(face)
        C.from_hb_bool(C.hb_ot_math_has_data(face.ptr))
      end

      # Returns a MATH constant value
      # @param font [Font] Sized font
      # @param constant [Integer] Math constant index
      # @return [Integer] Constant value in font units
      def constant(font, constant)
        C.hb_ot_math_get_constant(font.ptr, constant)
      end

      # @param font [Font] Sized font
      # @param glyph [Integer] Glyph ID
      # @return [Integer] Italics correction in font units
      def glyph_italics_correction(font, glyph)
        C.hb_ot_math_get_glyph_italics_correction(font.ptr, glyph)
      end

      # @param font [Font] Sized font
      # @param glyph [Integer] Glyph ID
      # @return [Integer] Top accent attachment in font units
      def glyph_top_accent_attachment(font, glyph)
        C.hb_ot_math_get_glyph_top_accent_attachment(font.ptr, glyph)
      end

      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Boolean] true if glyph is an extended shape
      def glyph_extended_shape?(face, glyph)
        C.from_hb_bool(C.hb_ot_math_is_glyph_extended_shape(face.ptr, glyph))
      end

      # Returns the math kerning value
      # @param font [Font] Sized font
      # @param glyph [Integer] Glyph ID
      # @param kern [Integer] Kern type
      # @param correction_height [Integer] Correction height
      # @return [Integer] Kerning value
      def glyph_kerning(font, glyph, kern, correction_height)
        C.hb_ot_math_get_glyph_kerning(font.ptr, glyph, kern, correction_height)
      end

      # Returns math glyph variants
      # @param font [Font] Sized font
      # @param glyph [Integer] Glyph ID
      # @param dir [Symbol] Direction
      # @return [Array<C::HbOtMathGlyphVariantT>] Variants
      def glyph_variants(font, glyph, dir)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_math_get_glyph_variants(font.ptr, glyph, dir, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        variants_ptr = FFI::MemoryPointer.new(C::HbOtMathGlyphVariantT, count)
        count_ptr.write_uint(count)
        C.hb_ot_math_get_glyph_variants(font.ptr, glyph, dir, 0, count_ptr, variants_ptr)
        actual = count_ptr.read_uint
        actual.times.map do |i|
          C::HbOtMathGlyphVariantT.new(variants_ptr + i * C::HbOtMathGlyphVariantT.size)
        end
      end

      # @param font [Font] Sized font
      # @param dir [Symbol] Direction
      # @return [Integer] Minimum connector overlap in font units
      def min_connector_overlap(font, dir)
        C.hb_ot_math_get_min_connector_overlap(font.ptr, dir)
      end
    end
  end
end

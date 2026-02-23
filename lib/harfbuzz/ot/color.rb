# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Color Fonts API (CPAL, COLR, SVG, CBDT/CBLC)
    module Color
      module_function

      # @param face [Face] Font face
      # @return [Boolean] true if the face has CPAL color palettes
      def has_palettes?(face)
        C.from_hb_bool(C.hb_ot_color_has_palettes(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Integer] Number of palettes
      def palette_count(face)
        C.hb_ot_color_palette_get_count(face.ptr)
      end

      # @param face [Face] Font face
      # @param idx [Integer] Palette index
      # @return [Integer] Name ID
      def palette_name_id(face, idx)
        C.hb_ot_color_palette_get_name_id(face.ptr, idx)
      end

      # @param face [Face] Font face
      # @param idx [Integer] Color index within palette
      # @return [Integer] Name ID
      def palette_color_name_id(face, idx)
        C.hb_ot_color_palette_color_get_name_id(face.ptr, idx)
      end

      # @param face [Face] Font face
      # @param idx [Integer] Palette index
      # @return [Integer] Palette flags bitmask
      def palette_flags(face, idx)
        C.hb_ot_color_palette_get_flags(face.ptr, idx)
      end

      # Returns colors in a palette
      # @param face [Face] Font face
      # @param idx [Integer] Palette index
      # @return [Array<Integer>] Array of RGBA color values
      def palette_colors(face, idx)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_color_palette_get_colors(face.ptr, idx, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        colors_ptr = FFI::MemoryPointer.new(:uint32, count)
        count_ptr.write_uint(count)
        C.hb_ot_color_palette_get_colors(face.ptr, idx, 0, count_ptr, colors_ptr)
        colors_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # @param face [Face] Font face
      # @return [Boolean] true if face has COLR layers
      def has_layers?(face)
        C.from_hb_bool(C.hb_ot_color_has_layers(face.ptr))
      end

      # Returns COLR layers for a glyph
      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Array<C::HbOtColorLayerT>] Layer array
      def glyph_layers(face, glyph)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_color_glyph_get_layers(face.ptr, glyph, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        layers_ptr = FFI::MemoryPointer.new(C::HbOtColorLayerT, count)
        count_ptr.write_uint(count)
        C.hb_ot_color_glyph_get_layers(face.ptr, glyph, 0, count_ptr, layers_ptr)
        actual = count_ptr.read_uint
        actual.times.map { |i| C::HbOtColorLayerT.new(layers_ptr + i * C::HbOtColorLayerT.size) }
      end

      # @param face [Face] Font face
      # @return [Boolean] true if face has SVG glyphs
      def has_svg?(face)
        C.from_hb_bool(C.hb_ot_color_has_svg(face.ptr))
      end

      # Returns the SVG blob for a glyph
      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Blob] SVG data blob
      def glyph_svg(face, glyph)
        Blob.wrap_owned(C.hb_ot_color_glyph_reference_svg(face.ptr, glyph))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if face has PNG glyphs
      def has_png?(face)
        C.from_hb_bool(C.hb_ot_color_has_png(face.ptr))
      end

      # Returns the PNG blob for a glyph at a given size
      # @param font [Font] Sized font
      # @param glyph [Integer] Glyph ID
      # @return [Blob] PNG data blob
      def glyph_png(font, glyph)
        Blob.wrap_owned(C.hb_ot_color_glyph_reference_png(font.ptr, glyph))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if face has COLRv1 paint data
      def has_paint?(face)
        C.from_hb_bool(C.hb_ot_color_has_paint(face.ptr))
      end

      # @param face [Face] Font face
      # @param glyph [Integer] Glyph ID
      # @return [Boolean] true if glyph has COLRv1 paint data
      def glyph_has_paint?(face, glyph)
        C.from_hb_bool(C.hb_ot_color_glyph_has_paint(face.ptr, glyph))
      end
    end
  end
end

# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_font_t — a sized, positioned font instance
  class Font
    attr_reader :ptr

    # Creates a Font from a Face
    # @param face [Face] Font face
    def initialize(face)
      @face = face
      @ptr = C.hb_font_create(face.ptr)
      raise AllocationError, "Failed to create font" if @ptr.null?

      register_finalizer
    end

    # Creates a sub-font of this font
    # @return [Font]
    def create_sub_font
      ptr = C.hb_font_create_sub_font(@ptr)
      self.class.wrap_owned(ptr)
    end

    # Returns the singleton empty font
    # @return [Font]
    def self.empty
      wrap_borrowed(C.hb_font_get_empty)
    end

    # Returns the face this font was created from (borrowed reference)
    # @return [Face]
    def face
      ptr = C.hb_font_get_face(@ptr)
      Face.wrap_borrowed(ptr)
    end

    # Returns scale as [x_scale, y_scale]
    # @return [Array<Integer>]
    def scale
      x_ptr = FFI::MemoryPointer.new(:int)
      y_ptr = FFI::MemoryPointer.new(:int)
      C.hb_font_get_scale(@ptr, x_ptr, y_ptr)
      [x_ptr.read_int, y_ptr.read_int]
    end

    # Sets font scale
    # @param xy [Array<Integer>, Integer] [x, y] or single value for both
    def scale=(xy)
      x, y = Array(xy).length == 2 ? xy : [xy, xy]
      C.hb_font_set_scale(@ptr, x, y)
    end

    # Returns pixels per em as [x_ppem, y_ppem]
    # @return [Array<Integer>]
    def ppem
      x_ptr = FFI::MemoryPointer.new(:uint)
      y_ptr = FFI::MemoryPointer.new(:uint)
      C.hb_font_get_ppem(@ptr, x_ptr, y_ptr)
      [x_ptr.read_uint, y_ptr.read_uint]
    end

    # Sets pixels per em
    # @param xy [Array<Integer>] [x_ppem, y_ppem]
    def ppem=(xy)
      x, y = xy
      C.hb_font_set_ppem(@ptr, x, y)
    end

    # @return [Float] Points per em
    def ptem
      C.hb_font_get_ptem(@ptr)
    end

    # @param pt [Float] Points per em
    def ptem=(pt)
      C.hb_font_set_ptem(@ptr, pt)
    end

    # Returns synthetic bold as [x_embolden, y_embolden, in_place]
    # @return [Array]
    def synthetic_bold
      x_ptr = FFI::MemoryPointer.new(:float)
      y_ptr = FFI::MemoryPointer.new(:float)
      ip_ptr = FFI::MemoryPointer.new(:int)
      C.hb_font_get_synthetic_bold(@ptr, x_ptr, y_ptr, ip_ptr)
      [x_ptr.read_float, y_ptr.read_float, C.from_hb_bool(ip_ptr.read_int)]
    end

    # Sets synthetic bold
    # @param xyz [Array] [x_embolden, y_embolden, in_place]
    def synthetic_bold=(xyz)
      x, y, ip = xyz
      C.hb_font_set_synthetic_bold(@ptr, x, y, C.to_hb_bool(ip))
    end

    # @return [Float] Synthetic slant
    def synthetic_slant
      C.hb_font_get_synthetic_slant(@ptr)
    end

    # @param slant [Float] Synthetic slant
    def synthetic_slant=(slant)
      C.hb_font_set_synthetic_slant(@ptr, slant)
    end

    # Sets variation axis values from an array of Variation objects
    # @param variations [Array<Variation>]
    def variations=(variations)
      structs = variations.map(&:to_struct)
      ptr = FFI::MemoryPointer.new(C::HbVariationT, structs.size)
      structs.each_with_index do |s, i|
        ptr.put_bytes(i * C::HbVariationT.size,
                      s.to_ptr.read_bytes(C::HbVariationT.size))
      end
      C.hb_font_set_variations(@ptr, ptr, structs.size)
      GC.keep_alive(structs)
    end

    # Sets a single variation axis value
    # @param tag [Integer] Axis tag
    # @param value [Float] Axis value
    def set_variation(tag, value)
      C.hb_font_set_variation(@ptr, tag, value)
    end

    # Sets design-space variation coordinates
    # @param coords [Array<Float>]
    def var_coords_design=(coords)
      ptr = FFI::MemoryPointer.new(:float, coords.size)
      ptr.put_array_of_float(0, coords)
      C.hb_font_set_var_coords_design(@ptr, ptr, coords.size)
    end

    # Returns design-space variation coordinates
    # @return [Array<Float>]
    def var_coords_design
      count_ptr = FFI::MemoryPointer.new(:uint)
      coords_ptr = C.hb_font_get_var_coords_design(@ptr, count_ptr)
      count = count_ptr.read_uint
      return [] if coords_ptr.null? || count.zero?

      coords_ptr.read_array_of_float(count)
    end

    # Sets normalized variation coordinates
    # @param coords [Array<Integer>]
    def var_coords_normalized=(coords)
      ptr = FFI::MemoryPointer.new(:int32, coords.size)
      ptr.put_array_of_int32(0, coords)
      C.hb_font_set_var_coords_normalized(@ptr, ptr, coords.size)
    end

    # Returns normalized variation coordinates
    # @return [Array<Integer>]
    def var_coords_normalized
      count_ptr = FFI::MemoryPointer.new(:uint)
      coords_ptr = C.hb_font_get_var_coords_normalized(@ptr, count_ptr)
      count = count_ptr.read_uint
      return [] if coords_ptr.null? || count.zero?

      coords_ptr.read_array_of_int32(count)
    end

    # @return [Boolean] true if font is immutable
    def immutable?
      C.from_hb_bool(C.hb_font_is_immutable(@ptr))
    end

    # Makes the font immutable (thread-safe to share after this)
    # @return [self]
    def make_immutable!
      C.hb_font_make_immutable(@ptr)
      self
    end

    # Returns glyph ID for a codepoint (with optional variation selector)
    # @param cp [Integer] Unicode codepoint
    # @param variation_selector [Integer] Variation selector codepoint (0 = none)
    # @return [Integer, nil] Glyph ID or nil if not found
    def glyph(cp, variation_selector = 0)
      glyph_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_font_get_glyph(@ptr, cp, variation_selector, glyph_ptr)
      ok.zero? ? nil : glyph_ptr.read_uint32
    end

    # Returns glyph ID for a nominal (non-variation) codepoint
    # @param cp [Integer] Unicode codepoint
    # @return [Integer, nil] Glyph ID or nil if not found
    def nominal_glyph(cp)
      glyph_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_font_get_nominal_glyph(@ptr, cp, glyph_ptr)
      ok.zero? ? nil : glyph_ptr.read_uint32
    end

    # Returns glyph ID for a variation sequence
    # @param cp [Integer] Unicode codepoint
    # @param selector [Integer] Variation selector
    # @return [Integer, nil] Glyph ID or nil if not found
    def variation_glyph(cp, selector)
      glyph_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_font_get_variation_glyph(@ptr, cp, selector, glyph_ptr)
      ok.zero? ? nil : glyph_ptr.read_uint32
    end

    # @param glyph [Integer] Glyph ID
    # @return [Integer] Horizontal advance in font units
    def glyph_h_advance(glyph)
      C.hb_font_get_glyph_h_advance(@ptr, glyph)
    end

    # @param glyph [Integer] Glyph ID
    # @return [Integer] Vertical advance in font units
    def glyph_v_advance(glyph)
      C.hb_font_get_glyph_v_advance(@ptr, glyph)
    end

    # Returns horizontal advances for multiple glyphs
    # @param glyphs [Array<Integer>] Glyph IDs
    # @return [Array<Integer>] Advances
    def glyph_h_advances(glyphs)
      count = glyphs.size
      glyph_ptr = FFI::MemoryPointer.new(:uint32, count)
      glyph_ptr.put_array_of_uint32(0, glyphs)
      advance_ptr = FFI::MemoryPointer.new(:int32, count)
      C.hb_font_get_glyph_h_advances(@ptr, count, glyph_ptr, 4, advance_ptr, 4)
      advance_ptr.read_array_of_int32(count)
    end

    # Returns vertical advances for multiple glyphs
    # @param glyphs [Array<Integer>] Glyph IDs
    # @return [Array<Integer>] Advances
    def glyph_v_advances(glyphs)
      count = glyphs.size
      glyph_ptr = FFI::MemoryPointer.new(:uint32, count)
      glyph_ptr.put_array_of_uint32(0, glyphs)
      advance_ptr = FFI::MemoryPointer.new(:int32, count)
      C.hb_font_get_glyph_v_advances(@ptr, count, glyph_ptr, 4, advance_ptr, 4)
      advance_ptr.read_array_of_int32(count)
    end

    # Returns horizontal origin for a glyph
    # @param glyph [Integer] Glyph ID
    # @return [Array<Integer>, nil] [x, y] or nil
    def glyph_h_origin(glyph)
      x_ptr = FFI::MemoryPointer.new(:int32)
      y_ptr = FFI::MemoryPointer.new(:int32)
      ok = C.hb_font_get_glyph_h_origin(@ptr, glyph, x_ptr, y_ptr)
      ok.zero? ? nil : [x_ptr.read_int32, y_ptr.read_int32]
    end

    # Returns vertical origin for a glyph
    # @param glyph [Integer] Glyph ID
    # @return [Array<Integer>, nil] [x, y] or nil
    def glyph_v_origin(glyph)
      x_ptr = FFI::MemoryPointer.new(:int32)
      y_ptr = FFI::MemoryPointer.new(:int32)
      ok = C.hb_font_get_glyph_v_origin(@ptr, glyph, x_ptr, y_ptr)
      ok.zero? ? nil : [x_ptr.read_int32, y_ptr.read_int32]
    end

    # Returns horizontal kerning between two glyphs
    # @param left [Integer] Left glyph ID
    # @param right [Integer] Right glyph ID
    # @return [Integer] Kerning value
    def glyph_h_kerning(left, right)
      C.hb_font_get_glyph_h_kerning(@ptr, left, right)
    end

    # Returns glyph extents
    # @param glyph [Integer] Glyph ID
    # @return [C::HbGlyphExtentsT, nil] Extents or nil
    def glyph_extents(glyph)
      extents = C::HbGlyphExtentsT.new
      ok = C.hb_font_get_glyph_extents(@ptr, glyph, extents)
      ok.zero? ? nil : extents
    end

    # Returns a contour point for a glyph
    # @param glyph [Integer] Glyph ID
    # @param idx [Integer] Contour point index
    # @return [Array<Integer>, nil] [x, y] or nil
    def glyph_contour_point(glyph, idx)
      x_ptr = FFI::MemoryPointer.new(:int32)
      y_ptr = FFI::MemoryPointer.new(:int32)
      ok = C.hb_font_get_glyph_contour_point(@ptr, glyph, idx, x_ptr, y_ptr)
      ok.zero? ? nil : [x_ptr.read_int32, y_ptr.read_int32]
    end

    # Returns the glyph name
    # @param glyph [Integer] Glyph ID
    # @return [String, nil] Glyph name or nil
    def glyph_name(glyph)
      buf = FFI::MemoryPointer.new(:char, 64)
      ok = C.hb_font_get_glyph_name(@ptr, glyph, buf, 64)
      ok.zero? ? nil : buf.read_string
    end

    # Returns the glyph ID for a name
    # @param name [String] Glyph name
    # @return [Integer, nil] Glyph ID or nil
    def glyph_from_name(name)
      glyph_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_font_get_glyph_from_name(@ptr, name, name.bytesize, glyph_ptr)
      ok.zero? ? nil : glyph_ptr.read_uint32
    end

    # Returns glyph advance for a direction as [x, y]
    # @param glyph [Integer] Glyph ID
    # @param dir [Symbol] Direction (:ltr, :rtl, :ttb, :btt)
    # @return [Array<Integer>] [x_advance, y_advance]
    def glyph_advance_for_direction(glyph, dir)
      x_ptr = FFI::MemoryPointer.new(:int32)
      y_ptr = FFI::MemoryPointer.new(:int32)
      C.hb_font_get_glyph_advance_for_direction(@ptr, glyph, dir, x_ptr, y_ptr)
      [x_ptr.read_int32, y_ptr.read_int32]
    end

    # Returns font extents for a direction
    # @param dir [Symbol] Direction (:ltr, :rtl, :ttb, :btt)
    # @return [C::HbFontExtentsT]
    def extents_for_direction(dir)
      extents = C::HbFontExtentsT.new
      C.hb_font_get_extents_for_direction(@ptr, dir, extents)
      extents
    end

    # Draws the outline of a glyph using DrawFuncs callbacks
    # @param glyph [Integer] Glyph ID
    # @param draw_funcs [DrawFuncs] Draw callbacks object
    def draw_glyph(glyph, draw_funcs)
      C.hb_font_draw_glyph(@ptr, glyph, draw_funcs.ptr, nil)
    end

    def inspect
      "#<HarfBuzz::Font scale=#{scale} ppem=#{ppem} immutable=#{immutable?}>"
    end

    def self.wrap_owned(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.send(:register_finalizer)
      obj
    end

    def self.wrap_borrowed(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.instance_variable_set(:@borrowed, true)
      obj
    end

    private

    def register_finalizer
      return if instance_variable_defined?(:@borrowed) && @borrowed

      HarfBuzz::Font.define_finalizer(self, @ptr)
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_font_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

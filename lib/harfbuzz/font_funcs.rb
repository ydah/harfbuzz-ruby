# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_font_funcs_t — customizable font callback table
  #
  # FontFuncs allows you to override how HarfBuzz queries glyph data from a font.
  # This is used to implement custom font backends (e.g., connecting to FreeType,
  # CoreText, or a custom renderer).
  #
  # @example Custom nominal glyph lookup
  #   funcs = HarfBuzz::FontFuncs.new
  #   funcs.on_nominal_glyph do |_font, codepoint|
  #     my_cmap[codepoint]
  #   end
  #   funcs.make_immutable!
  #   font.set_funcs(funcs)
  class FontFuncs
    attr_reader :ptr

    def initialize
      @ptr = C.hb_font_funcs_create
      raise AllocationError, "Failed to create font funcs" if @ptr.null?

      # Keep FFI::Function objects alive as long as this object is alive
      @callbacks = {}
      HarfBuzz::FontFuncs.define_finalizer(self, @ptr)
    end

    # Returns the singleton empty font funcs
    # @return [FontFuncs]
    def self.empty
      obj = allocate
      obj.instance_variable_set(:@ptr, C.hb_font_funcs_get_empty)
      obj.instance_variable_set(:@borrowed, true)
      obj.instance_variable_set(:@callbacks, {})
      obj
    end

    # @return [Boolean] true if immutable
    def immutable?
      C.from_hb_bool(C.hb_font_funcs_is_immutable(@ptr))
    end

    # Makes the funcs table immutable (required before attaching to a font)
    # @return [self]
    def make_immutable!
      C.hb_font_funcs_make_immutable(@ptr)
      self
    end

    # Sets the horizontal font extents callback
    # @yield [font] Called with the HarfBuzz font pointer
    # @yieldreturn [Hash, nil] Hash with :ascender, :descender, :line_gap keys (in font units), or nil
    def on_font_h_extents(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, extents_ptr, _user_data|
        result = block.call(font_ptr)
        next 0 unless result

        extents = C::HbFontExtentsT.new(extents_ptr)
        extents[:ascender] = result[:ascender] || 0
        extents[:descender] = result[:descender] || 0
        extents[:line_gap] = result[:line_gap] || 0
        1
      end
      @callbacks[:font_h_extents] = cb
      C.hb_font_funcs_set_font_h_extents_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the vertical font extents callback
    # @yield [font] Called with the HarfBuzz font pointer
    # @yieldreturn [Hash, nil] Hash with :ascender, :descender, :line_gap keys, or nil
    def on_font_v_extents(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, extents_ptr, _user_data|
        result = block.call(font_ptr)
        next 0 unless result

        extents = C::HbFontExtentsT.new(extents_ptr)
        extents[:ascender] = result[:ascender] || 0
        extents[:descender] = result[:descender] || 0
        extents[:line_gap] = result[:line_gap] || 0
        1
      end
      @callbacks[:font_v_extents] = cb
      C.hb_font_funcs_set_font_v_extents_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the nominal glyph lookup callback
    # @yield [font, codepoint] Called with font pointer and Unicode codepoint
    # @yieldreturn [Integer, nil] Glyph ID or nil if not found
    def on_nominal_glyph(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :pointer, :pointer]) do |font_ptr, _font_data, codepoint, glyph_out, _user_data|
        glyph_id = block.call(font_ptr, codepoint)
        next 0 unless glyph_id

        glyph_out.write_uint32(glyph_id)
        1
      end
      @callbacks[:nominal_glyph] = cb
      C.hb_font_funcs_set_nominal_glyph_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the variation glyph lookup callback
    # @yield [font, codepoint, variation_selector] Called with font pointer, codepoint, and selector
    # @yieldreturn [Integer, nil] Glyph ID or nil if not found
    def on_variation_glyph(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :uint32, :pointer, :pointer]) do |font_ptr, _font_data, codepoint, selector, glyph_out, _user_data|
        glyph_id = block.call(font_ptr, codepoint, selector)
        next 0 unless glyph_id

        glyph_out.write_uint32(glyph_id)
        1
      end
      @callbacks[:variation_glyph] = cb
      C.hb_font_funcs_set_variation_glyph_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the horizontal glyph advance callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [Integer] Horizontal advance in font units
    def on_glyph_h_advance(&block)
      cb = FFI::Function.new(:int32, [:pointer, :pointer, :uint32, :pointer]) do |font_ptr, _font_data, glyph, _user_data|
        block.call(font_ptr, glyph).to_i
      end
      @callbacks[:glyph_h_advance] = cb
      C.hb_font_funcs_set_glyph_h_advance_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the vertical glyph advance callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [Integer] Vertical advance in font units
    def on_glyph_v_advance(&block)
      cb = FFI::Function.new(:int32, [:pointer, :pointer, :uint32, :pointer]) do |font_ptr, _font_data, glyph, _user_data|
        block.call(font_ptr, glyph).to_i
      end
      @callbacks[:glyph_v_advance] = cb
      C.hb_font_funcs_set_glyph_v_advance_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the horizontal glyph origin callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [Array<Integer>, nil] [x, y] origin or nil
    def on_glyph_h_origin(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, glyph, x_out, y_out, _user_data|
        result = block.call(font_ptr, glyph)
        next 0 unless result

        x_out.write_int32(result[0])
        y_out.write_int32(result[1])
        1
      end
      @callbacks[:glyph_h_origin] = cb
      C.hb_font_funcs_set_glyph_h_origin_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the vertical glyph origin callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [Array<Integer>, nil] [x, y] origin or nil
    def on_glyph_v_origin(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, glyph, x_out, y_out, _user_data|
        result = block.call(font_ptr, glyph)
        next 0 unless result

        x_out.write_int32(result[0])
        y_out.write_int32(result[1])
        1
      end
      @callbacks[:glyph_v_origin] = cb
      C.hb_font_funcs_set_glyph_v_origin_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the horizontal glyph kerning callback
    # @yield [font, left_glyph, right_glyph] Called with font pointer and two glyph IDs
    # @yieldreturn [Integer] Kerning value in font units
    def on_glyph_h_kerning(&block)
      cb = FFI::Function.new(:int32, [:pointer, :pointer, :uint32, :uint32, :pointer]) do |font_ptr, _font_data, left, right, _user_data|
        block.call(font_ptr, left, right).to_i
      end
      @callbacks[:glyph_h_kerning] = cb
      C.hb_font_funcs_set_glyph_h_kerning_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the glyph extents callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [Hash, nil] Hash with :x_bearing, :y_bearing, :width, :height keys, or nil
    def on_glyph_extents(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :pointer, :pointer]) do |font_ptr, _font_data, glyph, extents_ptr, _user_data|
        result = block.call(font_ptr, glyph)
        next 0 unless result

        extents = C::HbGlyphExtentsT.new(extents_ptr)
        extents[:x_bearing] = result[:x_bearing] || 0
        extents[:y_bearing] = result[:y_bearing] || 0
        extents[:width] = result[:width] || 0
        extents[:height] = result[:height] || 0
        1
      end
      @callbacks[:glyph_extents] = cb
      C.hb_font_funcs_set_glyph_extents_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the glyph name callback
    # @yield [font, glyph] Called with font pointer and glyph ID
    # @yieldreturn [String, nil] Glyph name or nil
    def on_glyph_name(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :pointer, :uint, :pointer]) do |font_ptr, _font_data, glyph, name_buf, name_buf_size, _user_data|
        name = block.call(font_ptr, glyph)
        next 0 unless name

        bytes = name.bytesize
        size = [bytes, name_buf_size - 1].min
        name_buf.put_bytes(0, name, 0, size)
        name_buf.put_uint8(size, 0)  # null terminate
        1
      end
      @callbacks[:glyph_name] = cb
      C.hb_font_funcs_set_glyph_name_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the glyph-from-name lookup callback
    # @yield [font, name] Called with font pointer and glyph name string
    # @yieldreturn [Integer, nil] Glyph ID or nil if not found
    def on_glyph_from_name(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :pointer, :int, :pointer, :pointer]) do |font_ptr, _font_data, name_ptr, name_len, glyph_out, _user_data|
        name = name_len < 0 ? name_ptr.read_string : name_ptr.read_bytes(name_len)
        glyph_id = block.call(font_ptr, name)
        next 0 unless glyph_id

        glyph_out.write_uint32(glyph_id)
        1
      end
      @callbacks[:glyph_from_name] = cb
      C.hb_font_funcs_set_glyph_from_name_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the glyph contour point callback
    # @yield [font, glyph, point_index] Called with font pointer, glyph ID, and point index
    # @yieldreturn [Array<Integer>, nil] [x, y] contour point coordinates, or nil if not found
    def on_glyph_contour_point(&block)
      cb = FFI::Function.new(:int, [:pointer, :pointer, :uint32, :uint, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, glyph, point_index, x_out, y_out, _user_data|
        result = block.call(font_ptr, glyph, point_index)
        next 0 unless result

        x_out.write_int32(result[0])
        y_out.write_int32(result[1])
        1
      end
      @callbacks[:glyph_contour_point] = cb
      C.hb_font_funcs_set_glyph_contour_point_func(@ptr, cb, nil, nil)
      self
    end

    # Sets the draw glyph callback (called when font draws a glyph via draw funcs)
    # @yield [font, glyph, draw_funcs_ptr, draw_data_ptr] Called with font pointer, glyph ID, and draw state
    def on_draw_glyph(&block)
      cb = FFI::Function.new(:void, [:pointer, :pointer, :uint32, :pointer, :pointer, :pointer]) do |font_ptr, _font_data, glyph, draw_funcs_ptr, draw_data_ptr, _user_data|
        block.call(font_ptr, glyph, draw_funcs_ptr, draw_data_ptr)
      end
      @callbacks[:draw_glyph] = cb
      C.hb_font_funcs_set_draw_glyph_func(@ptr, cb, nil, nil)
      self
    end

    def inspect
      "#<HarfBuzz::FontFuncs immutable=#{immutable?}>"
    end

    def self.define_finalizer(obj, ptr)
      return if obj.instance_variable_defined?(:@borrowed) && obj.instance_variable_get(:@borrowed)

      destroy = C.method(:hb_font_funcs_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

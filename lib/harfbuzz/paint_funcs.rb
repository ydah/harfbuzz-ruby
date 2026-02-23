# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_paint_funcs_t — callbacks for color glyph rendering (COLRv1)
  class PaintFuncs
    attr_reader :ptr

    def initialize
      @ptr = C.hb_paint_funcs_create
      raise AllocationError, "Failed to create paint_funcs" if @ptr.null?

      HarfBuzz::PaintFuncs.define_finalizer(self, @ptr)
    end

    # @return [Boolean] true if immutable
    def immutable?
      C.from_hb_bool(C.hb_paint_funcs_is_immutable(@ptr))
    end

    # Makes immutable
    # @return [self]
    def make_immutable!
      C.hb_paint_funcs_make_immutable(@ptr)
      self
    end

    # Sets push_transform callback
    # @yield [xx, yx, xy, yy, dx, dy] 2D transform matrix components
    def on_push_transform(&block)
      @push_transform_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :float, :float, :float, :float, :float, :float, :pointer]) do
        |_pfuncs, _paint_data, xx, yx, xy, yy, dx, dy, _user_data|
        block.call(xx, yx, xy, yy, dx, dy)
      end
      @push_transform_ffi = cb
      C.hb_paint_funcs_set_push_transform_func(@ptr, cb, nil, nil)
    end

    # Sets pop_transform callback
    # @yield Called when a transform is popped
    def on_pop_transform(&block)
      @pop_transform_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :pointer]) do
        |_pfuncs, _paint_data, _user_data|
        block.call
      end
      @pop_transform_ffi = cb
      C.hb_paint_funcs_set_pop_transform_func(@ptr, cb, nil, nil)
    end

    # Sets push_clip_glyph callback
    # @yield [glyph] Glyph ID used as clip mask
    def on_push_clip_glyph(&block)
      @push_clip_glyph_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :uint32, :pointer, :pointer]) do
        |_pfuncs, _paint_data, glyph, _font, _user_data|
        block.call(glyph)
      end
      @push_clip_glyph_ffi = cb
      C.hb_paint_funcs_set_push_clip_glyph_func(@ptr, cb, nil, nil)
    end

    # Sets push_clip_rectangle callback
    # @yield [xmin, ymin, xmax, ymax]
    def on_push_clip_rectangle(&block)
      @push_clip_rectangle_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :float, :float, :float, :float, :pointer]) do
        |_pfuncs, _paint_data, xmin, ymin, xmax, ymax, _user_data|
        block.call(xmin, ymin, xmax, ymax)
      end
      @push_clip_rectangle_ffi = cb
      C.hb_paint_funcs_set_push_clip_rectangle_func(@ptr, cb, nil, nil)
    end

    # Sets pop_clip callback
    # @yield Called when clip is popped
    def on_pop_clip(&block)
      @pop_clip_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :pointer]) do
        |_pfuncs, _paint_data, _user_data|
        block.call
      end
      @pop_clip_ffi = cb
      C.hb_paint_funcs_set_pop_clip_func(@ptr, cb, nil, nil)
    end

    # Sets color callback
    # @yield [is_foreground, color] Color fill
    def on_color(&block)
      @color_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :int, :uint32, :pointer]) do
        |_pfuncs, _paint_data, is_foreground, color, _user_data|
        block.call(C.from_hb_bool(is_foreground), color)
      end
      @color_ffi = cb
      C.hb_paint_funcs_set_color_func(@ptr, cb, nil, nil)
    end

    # Sets push_group callback
    # @yield Called when a compositing group is started
    def on_push_group(&block)
      @push_group_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :pointer]) do
        |_pfuncs, _paint_data, _user_data|
        block.call
      end
      @push_group_ffi = cb
      C.hb_paint_funcs_set_push_group_func(@ptr, cb, nil, nil)
    end

    # Sets pop_group callback
    # @yield [mode] Composite mode
    def on_pop_group(&block)
      @pop_group_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :int, :pointer]) do
        |_pfuncs, _paint_data, mode, _user_data|
        block.call(mode)
      end
      @pop_group_ffi = cb
      C.hb_paint_funcs_set_pop_group_func(@ptr, cb, nil, nil)
    end

    def inspect
      "#<HarfBuzz::PaintFuncs immutable=#{immutable?}>"
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_paint_funcs_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_draw_funcs_t — callbacks for glyph outline rendering
  #
  # @example Extracting an SVG path
  #   draw = HarfBuzz::DrawFuncs.new
  #   path = []
  #   draw.on_move_to    { |x, y| path << "M#{x},#{y}" }
  #   draw.on_line_to    { |x, y| path << "L#{x},#{y}" }
  #   draw.on_cubic_to   { |c1x, c1y, c2x, c2y, x, y| path << "C#{c1x},#{c1y},#{c2x},#{c2y},#{x},#{y}" }
  #   draw.on_close_path { path << "Z" }
  #   draw.make_immutable!
  #   font.draw_glyph(glyph_id, draw)
  class DrawFuncs
    attr_reader :ptr

    def initialize
      @ptr = C.hb_draw_funcs_create
      raise AllocationError, "Failed to create draw_funcs" if @ptr.null?

      HarfBuzz::DrawFuncs.define_finalizer(self, @ptr)
    end

    # @return [Boolean] true if immutable
    def immutable?
      C.from_hb_bool(C.hb_draw_funcs_is_immutable(@ptr))
    end

    # Makes immutable (call after setting all callbacks)
    # @return [self]
    def make_immutable!
      C.hb_draw_funcs_make_immutable(@ptr)
      self
    end

    # Sets the move_to callback
    # @yield [x, y] Called for move-to operations
    def on_move_to(&block)
      @move_to_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :pointer, :float, :float, :pointer]) do
        |_dfuncs, _draw_data, _st, x, y, _user_data|
        block.call(x, y)
      end
      @move_to_ffi = cb
      C.hb_draw_funcs_set_move_to_func(@ptr, cb, nil, nil)
    end

    # Sets the line_to callback
    # @yield [x, y] Called for line-to operations
    def on_line_to(&block)
      @line_to_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :pointer, :float, :float, :pointer]) do
        |_dfuncs, _draw_data, _st, x, y, _user_data|
        block.call(x, y)
      end
      @line_to_ffi = cb
      C.hb_draw_funcs_set_line_to_func(@ptr, cb, nil, nil)
    end

    # Sets the quadratic_to callback
    # @yield [cx, cy, x, y] Control point and end point
    def on_quadratic_to(&block)
      @quadratic_to_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :pointer,
         :float, :float, :float, :float, :pointer]) do
        |_dfuncs, _draw_data, _st, cx, cy, x, y, _user_data|
        block.call(cx, cy, x, y)
      end
      @quadratic_to_ffi = cb
      C.hb_draw_funcs_set_quadratic_to_func(@ptr, cb, nil, nil)
    end

    # Sets the cubic_to callback
    # @yield [c1x, c1y, c2x, c2y, x, y] Two control points and end point
    def on_cubic_to(&block)
      @cubic_to_callback = block
      cb = FFI::Function.new(:void,
        [:pointer, :pointer, :pointer,
         :float, :float, :float, :float, :float, :float, :pointer]) do
        |_dfuncs, _draw_data, _st, c1x, c1y, c2x, c2y, x, y, _user_data|
        block.call(c1x, c1y, c2x, c2y, x, y)
      end
      @cubic_to_ffi = cb
      C.hb_draw_funcs_set_cubic_to_func(@ptr, cb, nil, nil)
    end

    # Sets the close_path callback
    # @yield Called when a path is closed
    def on_close_path(&block)
      @close_path_callback = block
      cb = FFI::Function.new(:void, [:pointer, :pointer, :pointer, :pointer]) do
        |_dfuncs, _draw_data, _st, _user_data|
        block.call
      end
      @close_path_ffi = cb
      C.hb_draw_funcs_set_close_path_func(@ptr, cb, nil, nil)
    end

    def inspect
      "#<HarfBuzz::DrawFuncs immutable=#{immutable?}>"
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_draw_funcs_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

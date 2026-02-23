# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_shape,
      [:hb_font_t, :hb_buffer_t, :pointer, :uint], :void
    attach_function :hb_shape_full,
      [:hb_font_t, :hb_buffer_t, :pointer, :uint, :pointer], :hb_bool_t
    attach_function :hb_shape_list_shapers, [], :pointer
  end
end

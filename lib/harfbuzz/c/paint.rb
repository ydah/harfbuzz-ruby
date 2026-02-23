# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_paint_funcs_create, [], :hb_paint_funcs_t
    attach_function :hb_paint_funcs_destroy, [:hb_paint_funcs_t], :void
    attach_function :hb_paint_funcs_reference, [:hb_paint_funcs_t], :hb_paint_funcs_t
    attach_function :hb_paint_funcs_is_immutable, [:hb_paint_funcs_t], :hb_bool_t
    attach_function :hb_paint_funcs_make_immutable, [:hb_paint_funcs_t], :void

    attach_function :hb_paint_funcs_set_push_transform_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_pop_transform_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_push_clip_glyph_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_push_clip_rectangle_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_pop_clip_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_color_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_linear_gradient_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_radial_gradient_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_sweep_gradient_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_push_group_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_pop_group_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_image_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_paint_funcs_set_custom_palette_color_func,
      [:hb_paint_funcs_t, :pointer, :pointer, :pointer], :void
  end
end

# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_font_funcs_create, [], :hb_font_funcs_t
    attach_function :hb_font_funcs_destroy, [:hb_font_funcs_t], :void
    attach_function :hb_font_funcs_reference, [:hb_font_funcs_t], :hb_font_funcs_t
    attach_function :hb_font_funcs_get_empty, [], :hb_font_funcs_t
    attach_function :hb_font_funcs_is_immutable, [:hb_font_funcs_t], :hb_bool_t
    attach_function :hb_font_funcs_make_immutable, [:hb_font_funcs_t], :void

    # Callback setter signatures:
    # Each takes (funcs, callback, user_data, destroy_notify)
    # We use :pointer for the callback and nil/NULL for user_data/destroy.

    attach_function :hb_font_funcs_set_font_h_extents_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_font_v_extents_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_nominal_glyph_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_variation_glyph_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_h_advance_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_v_advance_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_h_origin_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_v_origin_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_h_kerning_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_extents_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_contour_point_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_name_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_glyph_from_name_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_font_funcs_set_draw_glyph_func,
      [:hb_font_funcs_t, :pointer, :pointer, :pointer], :void
  end
end

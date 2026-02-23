# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_font_create, [:hb_face_t], :hb_font_t
    attach_function :hb_font_create_sub_font, [:hb_font_t], :hb_font_t
    attach_function :hb_font_destroy, [:hb_font_t], :void
    attach_function :hb_font_reference, [:hb_font_t], :hb_font_t
    attach_function :hb_font_get_empty, [], :hb_font_t

    attach_function :hb_font_get_face, [:hb_font_t], :hb_face_t
    attach_function :hb_font_set_face, [:hb_font_t, :hb_face_t], :void

    attach_function :hb_font_set_funcs,
      [:hb_font_t, :hb_font_funcs_t, :pointer, :pointer], :void

    attach_function :hb_font_get_scale, [:hb_font_t, :pointer, :pointer], :void
    attach_function :hb_font_set_scale, [:hb_font_t, :int, :int], :void
    attach_function :hb_font_get_ppem, [:hb_font_t, :pointer, :pointer], :void
    attach_function :hb_font_set_ppem, [:hb_font_t, :uint, :uint], :void
    attach_function :hb_font_get_ptem, [:hb_font_t], :float
    attach_function :hb_font_set_ptem, [:hb_font_t, :float], :void

    attach_function :hb_font_set_synthetic_bold, [:hb_font_t, :float, :float, :hb_bool_t], :void
    attach_function :hb_font_get_synthetic_bold, [:hb_font_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_font_set_synthetic_slant, [:hb_font_t, :float], :void
    attach_function :hb_font_get_synthetic_slant, [:hb_font_t], :float

    attach_function :hb_font_set_variations, [:hb_font_t, :pointer, :uint], :void
    attach_function :hb_font_set_variation, [:hb_font_t, :hb_tag_t, :float], :void

    attach_function :hb_font_set_var_coords_design, [:hb_font_t, :pointer, :uint], :void
    attach_function :hb_font_get_var_coords_design, [:hb_font_t, :pointer], :pointer
    attach_function :hb_font_set_var_coords_normalized, [:hb_font_t, :pointer, :uint], :void
    attach_function :hb_font_get_var_coords_normalized, [:hb_font_t, :pointer], :pointer

    attach_function :hb_font_is_immutable, [:hb_font_t], :hb_bool_t
    attach_function :hb_font_make_immutable, [:hb_font_t], :void

    attach_function :hb_font_get_glyph,
      [:hb_font_t, :hb_codepoint_t, :hb_codepoint_t, :pointer], :hb_bool_t
    attach_function :hb_font_get_nominal_glyph,
      [:hb_font_t, :hb_codepoint_t, :pointer], :hb_bool_t
    attach_function :hb_font_get_nominal_glyphs,
      [:hb_font_t, :uint, :pointer, :uint, :pointer, :uint], :uint
    attach_function :hb_font_get_variation_glyph,
      [:hb_font_t, :hb_codepoint_t, :hb_codepoint_t, :pointer], :hb_bool_t

    attach_function :hb_font_get_glyph_h_advance, [:hb_font_t, :hb_codepoint_t], :hb_position_t
    attach_function :hb_font_get_glyph_v_advance, [:hb_font_t, :hb_codepoint_t], :hb_position_t
    attach_function :hb_font_get_glyph_h_advances,
      [:hb_font_t, :uint, :pointer, :uint, :pointer, :uint], :void
    attach_function :hb_font_get_glyph_v_advances,
      [:hb_font_t, :uint, :pointer, :uint, :pointer, :uint], :void

    attach_function :hb_font_get_glyph_h_origin,
      [:hb_font_t, :hb_codepoint_t, :pointer, :pointer], :hb_bool_t
    attach_function :hb_font_get_glyph_v_origin,
      [:hb_font_t, :hb_codepoint_t, :pointer, :pointer], :hb_bool_t

    attach_function :hb_font_get_glyph_h_kerning,
      [:hb_font_t, :hb_codepoint_t, :hb_codepoint_t], :hb_position_t

    attach_function :hb_font_get_glyph_extents,
      [:hb_font_t, :hb_codepoint_t, :pointer], :hb_bool_t
    attach_function :hb_font_get_glyph_contour_point,
      [:hb_font_t, :hb_codepoint_t, :uint, :pointer, :pointer], :hb_bool_t

    attach_function :hb_font_get_glyph_name,
      [:hb_font_t, :hb_codepoint_t, :pointer, :uint], :hb_bool_t
    attach_function :hb_font_get_glyph_from_name,
      [:hb_font_t, :string, :int, :pointer], :hb_bool_t

    attach_function :hb_font_get_extents_for_direction,
      [:hb_font_t, :hb_direction_t, :pointer], :void

    attach_function :hb_font_draw_glyph,
      [:hb_font_t, :hb_codepoint_t, :hb_draw_funcs_t, :pointer], :void
    attach_function :hb_font_paint_glyph,
      [:hb_font_t, :hb_codepoint_t, :hb_paint_funcs_t, :pointer, :uint, :hb_color_t], :void

    attach_function :hb_font_set_user_data,
      [:hb_font_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_font_get_user_data, [:hb_font_t, :pointer], :pointer
  end
end

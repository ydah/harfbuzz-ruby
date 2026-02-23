# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_math_has_data, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_math_get_constant, [:hb_font_t, :uint], :hb_position_t
    attach_function :hb_ot_math_get_glyph_italics_correction,
      [:hb_font_t, :hb_codepoint_t], :hb_position_t
    attach_function :hb_ot_math_get_glyph_top_accent_attachment,
      [:hb_font_t, :hb_codepoint_t], :hb_position_t
    attach_function :hb_ot_math_is_glyph_extended_shape,
      [:hb_face_t, :hb_codepoint_t], :hb_bool_t
    attach_function :hb_ot_math_get_glyph_kerning,
      [:hb_font_t, :hb_codepoint_t, :uint, :hb_position_t], :hb_position_t
    attach_function :hb_ot_math_get_glyph_variants,
      [:hb_font_t, :hb_codepoint_t, :hb_direction_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_math_get_glyph_assembly,
      [:hb_font_t, :hb_codepoint_t, :hb_direction_t,
       :uint, :pointer, :pointer, :pointer], :uint
    attach_function :hb_ot_math_get_min_connector_overlap,
      [:hb_font_t, :hb_direction_t], :hb_position_t
  end
end

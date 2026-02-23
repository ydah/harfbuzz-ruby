# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_color_has_palettes, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_color_palette_get_count, [:hb_face_t], :uint
    attach_function :hb_ot_color_palette_get_name_id,
      [:hb_face_t, :uint], :hb_ot_name_id_t
    attach_function :hb_ot_color_palette_color_get_name_id,
      [:hb_face_t, :uint], :hb_ot_name_id_t
    attach_function :hb_ot_color_palette_get_flags,
      [:hb_face_t, :uint], :uint
    attach_function :hb_ot_color_palette_get_colors,
      [:hb_face_t, :uint, :uint, :pointer, :pointer], :uint

    attach_function :hb_ot_color_has_layers, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_color_glyph_get_layers,
      [:hb_face_t, :hb_codepoint_t, :uint, :pointer, :pointer], :uint

    attach_function :hb_ot_color_has_svg, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_color_glyph_reference_svg,
      [:hb_face_t, :hb_codepoint_t], :hb_blob_t

    attach_function :hb_ot_color_has_png, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_color_glyph_reference_png,
      [:hb_font_t, :hb_codepoint_t], :hb_blob_t

    attach_function :hb_ot_color_has_paint, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_color_glyph_has_paint,
      [:hb_face_t, :hb_codepoint_t], :hb_bool_t
  end
end

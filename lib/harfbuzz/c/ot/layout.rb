# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_layout_has_glyph_classes, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_layout_has_substitution, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_layout_has_positioning, [:hb_face_t], :hb_bool_t

    attach_function :hb_ot_layout_get_glyph_class,
      [:hb_face_t, :hb_codepoint_t], :hb_ot_layout_glyph_class_t
    attach_function :hb_ot_layout_get_glyphs_in_class,
      [:hb_face_t, :hb_ot_layout_glyph_class_t, :hb_set_t], :void

    attach_function :hb_ot_layout_get_attach_points,
      [:hb_face_t, :hb_codepoint_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_get_ligature_carets,
      [:hb_font_t, :hb_direction_t, :hb_codepoint_t, :uint, :pointer, :pointer], :uint

    attach_function :hb_ot_layout_table_get_script_tags,
      [:hb_face_t, :hb_tag_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_table_find_script,
      [:hb_face_t, :hb_tag_t, :hb_tag_t, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_table_select_script,
      [:hb_face_t, :hb_tag_t, :uint, :pointer, :pointer, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_table_get_feature_tags,
      [:hb_face_t, :hb_tag_t, :uint, :pointer, :pointer], :uint

    attach_function :hb_ot_layout_script_get_language_tags,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_script_select_language,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer, :pointer], :hb_bool_t

    attach_function :hb_ot_layout_language_get_required_feature_index,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_language_get_required_feature,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_language_get_feature_indexes,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_language_get_feature_tags,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_language_find_feature,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :hb_tag_t, :pointer], :hb_bool_t

    attach_function :hb_ot_layout_feature_get_lookups,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_layout_collect_lookups,
      [:hb_face_t, :hb_tag_t, :pointer, :pointer, :pointer, :hb_set_t], :void
    attach_function :hb_ot_layout_collect_features,
      [:hb_face_t, :hb_tag_t, :pointer, :pointer, :pointer, :hb_set_t], :void

    attach_function :hb_ot_layout_get_size_params,
      [:hb_face_t, :pointer, :pointer, :pointer, :pointer, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_feature_get_name_ids,
      [:hb_face_t, :hb_tag_t, :uint, :pointer, :pointer, :pointer, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_feature_get_characters,
      [:hb_face_t, :hb_tag_t, :uint, :uint, :pointer, :pointer], :uint

    attach_function :hb_ot_layout_get_baseline,
      [:hb_font_t, :uint, :hb_direction_t, :uint32, :pointer, :pointer], :hb_bool_t
    attach_function :hb_ot_layout_get_baseline_with_fallback,
      [:hb_font_t, :uint, :hb_direction_t, :uint32, :pointer, :pointer], :void
    attach_function :hb_ot_layout_get_font_extents,
      [:hb_font_t, :hb_direction_t, :uint32, :pointer, :pointer], :hb_bool_t

    attach_function :hb_ot_layout_get_horizontal_baseline_tag_for_script,
      [:uint32], :uint

    attach_function :hb_ot_tags_from_script_and_language,
      [:uint32, :pointer, :pointer, :pointer, :pointer, :pointer], :void
    attach_function :hb_ot_tags_to_script_and_language,
      [:hb_tag_t, :hb_tag_t, :pointer, :pointer], :void
    attach_function :hb_ot_tag_to_language, [:hb_tag_t], :pointer
    attach_function :hb_ot_tag_to_script, [:hb_tag_t], :uint32
  end
end

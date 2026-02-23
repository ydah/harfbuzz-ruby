# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_face_create, [:hb_blob_t, :uint], :hb_face_t
    attach_function :hb_face_create_for_tables, [:pointer, :pointer, :pointer], :hb_face_t
    attach_function :hb_face_destroy, [:hb_face_t], :void
    attach_function :hb_face_reference, [:hb_face_t], :hb_face_t
    attach_function :hb_face_get_empty, [], :hb_face_t
    attach_function :hb_face_count, [:hb_blob_t], :uint

    attach_function :hb_face_get_index, [:hb_face_t], :uint
    attach_function :hb_face_set_index, [:hb_face_t, :uint], :void
    attach_function :hb_face_get_upem, [:hb_face_t], :uint
    attach_function :hb_face_set_upem, [:hb_face_t, :uint], :void
    attach_function :hb_face_get_glyph_count, [:hb_face_t], :uint
    attach_function :hb_face_set_glyph_count, [:hb_face_t, :uint], :void

    attach_function :hb_face_get_table_tags, [:hb_face_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_face_reference_table, [:hb_face_t, :hb_tag_t], :hb_blob_t
    attach_function :hb_face_reference_blob, [:hb_face_t], :hb_blob_t

    attach_function :hb_face_is_immutable, [:hb_face_t], :hb_bool_t
    attach_function :hb_face_make_immutable, [:hb_face_t], :void

    attach_function :hb_face_collect_unicodes, [:hb_face_t, :hb_set_t], :void
    attach_function :hb_face_collect_nominal_glyph_mapping,
      [:hb_face_t, :hb_map_t, :hb_set_t], :void
    attach_function :hb_face_collect_variation_selectors, [:hb_face_t, :hb_set_t], :void
    attach_function :hb_face_collect_variation_unicodes,
      [:hb_face_t, :hb_codepoint_t, :hb_set_t], :void

    attach_function :hb_face_set_user_data,
      [:hb_face_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_face_get_user_data, [:hb_face_t, :pointer], :pointer
  end
end

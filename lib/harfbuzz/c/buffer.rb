# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_buffer_create, [], :hb_buffer_t
    attach_function :hb_buffer_create_similar, [:hb_buffer_t], :hb_buffer_t
    attach_function :hb_buffer_destroy, [:hb_buffer_t], :void
    attach_function :hb_buffer_reference, [:hb_buffer_t], :hb_buffer_t
    attach_function :hb_buffer_get_empty, [], :hb_buffer_t
    attach_function :hb_buffer_reset, [:hb_buffer_t], :void
    attach_function :hb_buffer_clear_contents, [:hb_buffer_t], :void
    attach_function :hb_buffer_pre_allocate, [:hb_buffer_t, :uint], :hb_bool_t
    attach_function :hb_buffer_allocation_successful, [:hb_buffer_t], :hb_bool_t

    attach_function :hb_buffer_add, [:hb_buffer_t, :hb_codepoint_t, :uint], :void
    attach_function :hb_buffer_add_utf8,
      [:hb_buffer_t, :pointer, :int, :uint, :int], :void
    attach_function :hb_buffer_add_utf16,
      [:hb_buffer_t, :pointer, :int, :uint, :int], :void
    attach_function :hb_buffer_add_utf32,
      [:hb_buffer_t, :pointer, :int, :uint, :int], :void
    attach_function :hb_buffer_add_latin1,
      [:hb_buffer_t, :pointer, :int, :uint, :int], :void
    attach_function :hb_buffer_add_codepoints,
      [:hb_buffer_t, :pointer, :int, :uint, :int], :void
    attach_function :hb_buffer_append,
      [:hb_buffer_t, :hb_buffer_t, :uint, :uint], :void

    attach_function :hb_buffer_set_content_type,
      [:hb_buffer_t, :hb_buffer_content_type_t], :void
    attach_function :hb_buffer_get_content_type,
      [:hb_buffer_t], :hb_buffer_content_type_t

    attach_function :hb_buffer_set_unicode_funcs,
      [:hb_buffer_t, :hb_unicode_funcs_t], :void
    attach_function :hb_buffer_get_unicode_funcs,
      [:hb_buffer_t], :hb_unicode_funcs_t

    attach_function :hb_buffer_set_direction,
      [:hb_buffer_t, :hb_direction_t], :void
    attach_function :hb_buffer_get_direction,
      [:hb_buffer_t], :hb_direction_t

    attach_function :hb_buffer_set_script, [:hb_buffer_t, :uint32], :void
    attach_function :hb_buffer_get_script, [:hb_buffer_t], :uint32

    attach_function :hb_buffer_set_language, [:hb_buffer_t, :pointer], :void
    attach_function :hb_buffer_get_language, [:hb_buffer_t], :pointer

    attach_function :hb_buffer_set_segment_properties,
      [:hb_buffer_t, :pointer], :void
    attach_function :hb_buffer_get_segment_properties,
      [:hb_buffer_t, :pointer], :void
    attach_function :hb_buffer_guess_segment_properties, [:hb_buffer_t], :void

    attach_function :hb_buffer_set_flags, [:hb_buffer_t, :uint], :void
    attach_function :hb_buffer_get_flags, [:hb_buffer_t], :uint

    attach_function :hb_buffer_set_cluster_level,
      [:hb_buffer_t, :hb_buffer_cluster_level_t], :void
    attach_function :hb_buffer_get_cluster_level,
      [:hb_buffer_t], :hb_buffer_cluster_level_t

    attach_function :hb_buffer_set_replacement_codepoint,
      [:hb_buffer_t, :hb_codepoint_t], :void
    attach_function :hb_buffer_get_replacement_codepoint,
      [:hb_buffer_t], :hb_codepoint_t

    attach_function :hb_buffer_set_invisible_glyph,
      [:hb_buffer_t, :hb_codepoint_t], :void
    attach_function :hb_buffer_get_invisible_glyph,
      [:hb_buffer_t], :hb_codepoint_t

    attach_function :hb_buffer_set_not_found_glyph,
      [:hb_buffer_t, :hb_codepoint_t], :void
    attach_function :hb_buffer_get_not_found_glyph,
      [:hb_buffer_t], :hb_codepoint_t

    attach_function :hb_buffer_set_random_state, [:hb_buffer_t, :uint], :void
    attach_function :hb_buffer_get_random_state, [:hb_buffer_t], :uint

    attach_function :hb_buffer_set_length, [:hb_buffer_t, :uint], :hb_bool_t
    attach_function :hb_buffer_get_length, [:hb_buffer_t], :uint

    attach_function :hb_buffer_get_glyph_infos, [:hb_buffer_t, :pointer], :pointer
    attach_function :hb_buffer_get_glyph_positions, [:hb_buffer_t, :pointer], :pointer
    attach_function :hb_buffer_has_positions, [:hb_buffer_t], :hb_bool_t

    attach_function :hb_buffer_normalize_glyphs, [:hb_buffer_t], :void
    attach_function :hb_buffer_reverse, [:hb_buffer_t], :void
    attach_function :hb_buffer_reverse_range, [:hb_buffer_t, :uint, :uint], :void
    attach_function :hb_buffer_reverse_clusters, [:hb_buffer_t], :void

    attach_function :hb_buffer_serialize_glyphs,
      [:hb_buffer_t, :uint, :uint, :pointer, :uint, :pointer,
       :hb_font_t, :hb_buffer_serialize_format_t, :uint], :uint
    attach_function :hb_buffer_serialize_unicode,
      [:hb_buffer_t, :uint, :uint, :pointer, :uint, :pointer,
       :hb_buffer_serialize_format_t, :uint], :uint
    attach_function :hb_buffer_serialize_format_from_string, [:string, :int],
      :hb_buffer_serialize_format_t
    attach_function :hb_buffer_serialize_format_to_string,
      [:hb_buffer_serialize_format_t], :string
    attach_function :hb_buffer_serialize_list_formats, [], :pointer

    attach_function :hb_buffer_deserialize_glyphs,
      [:hb_buffer_t, :string, :int, :pointer, :hb_font_t,
       :hb_buffer_serialize_format_t], :hb_bool_t
    attach_function :hb_buffer_deserialize_unicode,
      [:hb_buffer_t, :string, :int, :pointer,
       :hb_buffer_serialize_format_t], :hb_bool_t

    attach_function :hb_buffer_diff,
      [:hb_buffer_t, :hb_buffer_t, :hb_codepoint_t, :uint], :uint

    attach_function :hb_buffer_set_message_func,
      [:hb_buffer_t, :pointer, :pointer, :pointer], :void
  end
end

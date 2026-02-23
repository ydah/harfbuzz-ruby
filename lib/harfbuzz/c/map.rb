# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_map_create, [], :hb_map_t
    attach_function :hb_map_destroy, [:hb_map_t], :void
    attach_function :hb_map_reference, [:hb_map_t], :hb_map_t
    attach_function :hb_map_get_empty, [], :hb_map_t
    attach_function :hb_map_clear, [:hb_map_t], :void
    attach_function :hb_map_is_empty, [:hb_map_t], :hb_bool_t
    attach_function :hb_map_get_population, [:hb_map_t], :uint
    attach_function :hb_map_has, [:hb_map_t, :hb_codepoint_t], :hb_bool_t
    attach_function :hb_map_get, [:hb_map_t, :hb_codepoint_t], :hb_codepoint_t
    attach_function :hb_map_set, [:hb_map_t, :hb_codepoint_t, :hb_codepoint_t], :void
    attach_function :hb_map_del, [:hb_map_t, :hb_codepoint_t], :void
    attach_function :hb_map_is_equal, [:hb_map_t, :hb_map_t], :hb_bool_t
    attach_function :hb_map_hash, [:hb_map_t], :uint
    attach_function :hb_map_allocation_successful, [:hb_map_t], :hb_bool_t
    attach_function :hb_map_keys, [:hb_map_t, :hb_set_t], :void
    attach_function :hb_map_values, [:hb_map_t, :hb_set_t], :void
    attach_function :hb_map_next, [:hb_map_t, :pointer, :pointer, :pointer], :hb_bool_t
    attach_function :hb_map_update, [:hb_map_t, :hb_map_t], :void

    attach_function :hb_map_set_user_data,
      [:hb_map_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_map_get_user_data, [:hb_map_t, :pointer], :pointer
  end
end

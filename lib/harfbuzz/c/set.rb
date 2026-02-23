# frozen_string_literal: true

module HarfBuzz
  module C
    HB_SET_VALUE_INVALID = 0xFFFFFFFF

    attach_function :hb_set_create, [], :hb_set_t
    attach_function :hb_set_destroy, [:hb_set_t], :void
    attach_function :hb_set_reference, [:hb_set_t], :hb_set_t
    attach_function :hb_set_get_empty, [], :hb_set_t
    attach_function :hb_set_clear, [:hb_set_t], :void
    attach_function :hb_set_is_empty, [:hb_set_t], :hb_bool_t
    attach_function :hb_set_get_population, [:hb_set_t], :uint
    attach_function :hb_set_has, [:hb_set_t, :hb_codepoint_t], :hb_bool_t
    attach_function :hb_set_add, [:hb_set_t, :hb_codepoint_t], :void
    attach_function :hb_set_add_range, [:hb_set_t, :hb_codepoint_t, :hb_codepoint_t], :void
    attach_function :hb_set_add_sorted_array,
      [:hb_set_t, :pointer, :uint], :void
    attach_function :hb_set_del, [:hb_set_t, :hb_codepoint_t], :void
    attach_function :hb_set_del_range, [:hb_set_t, :hb_codepoint_t, :hb_codepoint_t], :void
    attach_function :hb_set_is_equal, [:hb_set_t, :hb_set_t], :hb_bool_t
    attach_function :hb_set_hash, [:hb_set_t], :uint
    attach_function :hb_set_is_subset, [:hb_set_t, :hb_set_t], :hb_bool_t
    attach_function :hb_set_set, [:hb_set_t, :hb_set_t], :void
    attach_function :hb_set_union, [:hb_set_t, :hb_set_t], :void
    attach_function :hb_set_intersect, [:hb_set_t, :hb_set_t], :void
    attach_function :hb_set_subtract, [:hb_set_t, :hb_set_t], :void
    attach_function :hb_set_symmetric_difference, [:hb_set_t, :hb_set_t], :void
    attach_function :hb_set_invert, [:hb_set_t], :void
    attach_function :hb_set_get_min, [:hb_set_t], :hb_codepoint_t
    attach_function :hb_set_get_max, [:hb_set_t], :hb_codepoint_t
    attach_function :hb_set_next, [:hb_set_t, :pointer], :hb_bool_t
    attach_function :hb_set_previous, [:hb_set_t, :pointer], :hb_bool_t
    attach_function :hb_set_next_range, [:hb_set_t, :pointer, :pointer], :hb_bool_t
    attach_function :hb_set_previous_range, [:hb_set_t, :pointer, :pointer], :hb_bool_t
    attach_function :hb_set_next_many, [:hb_set_t, :hb_codepoint_t, :pointer, :uint], :uint

    attach_function :hb_set_set_user_data,
      [:hb_set_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_set_get_user_data, [:hb_set_t, :pointer], :pointer
  end
end

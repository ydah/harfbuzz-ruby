# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_unicode_funcs_create, [:hb_unicode_funcs_t], :hb_unicode_funcs_t
    attach_function :hb_unicode_funcs_get_default, [], :hb_unicode_funcs_t
    attach_function :hb_unicode_funcs_get_empty, [], :hb_unicode_funcs_t
    attach_function :hb_unicode_funcs_destroy, [:hb_unicode_funcs_t], :void
    attach_function :hb_unicode_funcs_reference, [:hb_unicode_funcs_t], :hb_unicode_funcs_t
    attach_function :hb_unicode_funcs_get_parent, [:hb_unicode_funcs_t], :hb_unicode_funcs_t
    attach_function :hb_unicode_funcs_is_immutable, [:hb_unicode_funcs_t], :hb_bool_t
    attach_function :hb_unicode_funcs_make_immutable, [:hb_unicode_funcs_t], :void

    attach_function :hb_unicode_funcs_set_general_category_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_unicode_funcs_set_combining_class_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_unicode_funcs_set_mirroring_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_unicode_funcs_set_script_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_unicode_funcs_set_compose_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_unicode_funcs_set_decompose_func,
      [:hb_unicode_funcs_t, :pointer, :pointer, :pointer], :void

    attach_function :hb_unicode_general_category,
      [:hb_unicode_funcs_t, :hb_codepoint_t], :hb_unicode_general_category_t
    attach_function :hb_unicode_combining_class,
      [:hb_unicode_funcs_t, :hb_codepoint_t], :uint
    attach_function :hb_unicode_mirroring,
      [:hb_unicode_funcs_t, :hb_codepoint_t], :hb_codepoint_t
    attach_function :hb_unicode_script,
      [:hb_unicode_funcs_t, :hb_codepoint_t], :uint32
    attach_function :hb_unicode_compose,
      [:hb_unicode_funcs_t, :hb_codepoint_t, :hb_codepoint_t, :pointer], :hb_bool_t
    attach_function :hb_unicode_decompose,
      [:hb_unicode_funcs_t, :hb_codepoint_t, :pointer, :pointer], :hb_bool_t
  end
end

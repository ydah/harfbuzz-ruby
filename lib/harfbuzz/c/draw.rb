# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_draw_funcs_create, [], :hb_draw_funcs_t
    attach_function :hb_draw_funcs_destroy, [:hb_draw_funcs_t], :void
    attach_function :hb_draw_funcs_reference, [:hb_draw_funcs_t], :hb_draw_funcs_t
    attach_function :hb_draw_funcs_is_immutable, [:hb_draw_funcs_t], :hb_bool_t
    attach_function :hb_draw_funcs_make_immutable, [:hb_draw_funcs_t], :void

    attach_function :hb_draw_funcs_set_move_to_func,
      [:hb_draw_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_draw_funcs_set_line_to_func,
      [:hb_draw_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_draw_funcs_set_quadratic_to_func,
      [:hb_draw_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_draw_funcs_set_cubic_to_func,
      [:hb_draw_funcs_t, :pointer, :pointer, :pointer], :void
    attach_function :hb_draw_funcs_set_close_path_func,
      [:hb_draw_funcs_t, :pointer, :pointer, :pointer], :void
  end
end

# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_shape_plan_create,
      [:hb_face_t, :pointer, :pointer, :uint, :pointer], :hb_shape_plan_t
    attach_function :hb_shape_plan_create_cached,
      [:hb_face_t, :pointer, :pointer, :uint, :pointer], :hb_shape_plan_t
    attach_function :hb_shape_plan_create2,
      [:hb_face_t, :pointer, :pointer, :uint, :pointer, :uint, :pointer], :hb_shape_plan_t
    attach_function :hb_shape_plan_create_cached2,
      [:hb_face_t, :pointer, :pointer, :uint, :pointer, :uint, :pointer], :hb_shape_plan_t
    attach_function :hb_shape_plan_destroy, [:hb_shape_plan_t], :void
    attach_function :hb_shape_plan_reference, [:hb_shape_plan_t], :hb_shape_plan_t
    attach_function :hb_shape_plan_execute,
      [:hb_shape_plan_t, :hb_font_t, :hb_buffer_t, :pointer, :uint], :hb_bool_t
    attach_function :hb_shape_plan_get_shaper, [:hb_shape_plan_t], :string
    attach_function :hb_shape_plan_get_empty, [], :hb_shape_plan_t

    attach_function :hb_shape_plan_set_user_data,
      [:hb_shape_plan_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_shape_plan_get_user_data, [:hb_shape_plan_t, :pointer], :pointer
  end
end

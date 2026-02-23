# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_var_has_data, [:hb_face_t], :hb_bool_t
    attach_function :hb_ot_var_get_axis_count, [:hb_face_t], :uint
    attach_function :hb_ot_var_get_axis_infos, [:hb_face_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_var_find_axis_info,
      [:hb_face_t, :hb_tag_t, :pointer], :hb_bool_t
    attach_function :hb_ot_var_get_named_instance_count, [:hb_face_t], :uint
    attach_function :hb_ot_var_named_instance_get_subfamily_name_id,
      [:hb_face_t, :uint], :hb_ot_name_id_t
    attach_function :hb_ot_var_named_instance_get_postscript_name_id,
      [:hb_face_t, :uint], :hb_ot_name_id_t
    attach_function :hb_ot_var_named_instance_get_design_coords,
      [:hb_face_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_var_normalize_variations,
      [:hb_face_t, :pointer, :uint, :pointer, :uint], :void
    attach_function :hb_ot_var_normalize_coords,
      [:hb_face_t, :uint, :pointer, :pointer], :void
  end
end

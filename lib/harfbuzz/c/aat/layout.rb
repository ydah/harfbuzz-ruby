# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_aat_layout_has_substitution, [:hb_face_t], :hb_bool_t
    attach_function :hb_aat_layout_has_positioning, [:hb_face_t], :hb_bool_t
    attach_function :hb_aat_layout_has_tracking, [:hb_face_t], :hb_bool_t
    attach_function :hb_aat_layout_get_feature_types,
      [:hb_face_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_aat_layout_feature_type_get_name_id,
      [:hb_face_t, :uint, :pointer], :hb_bool_t
    attach_function :hb_aat_layout_feature_type_get_selector_infos,
      [:hb_face_t, :uint, :uint, :pointer, :pointer, :pointer], :uint
  end
end

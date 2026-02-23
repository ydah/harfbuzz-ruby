# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_name_list_names, [:hb_face_t, :pointer], :pointer
    attach_function :hb_ot_name_get_utf8,
      [:hb_face_t, :hb_ot_name_id_t, :pointer, :pointer, :pointer], :uint
    attach_function :hb_ot_name_get_utf16,
      [:hb_face_t, :hb_ot_name_id_t, :pointer, :pointer, :pointer], :uint
    attach_function :hb_ot_name_get_utf32,
      [:hb_face_t, :hb_ot_name_id_t, :pointer, :pointer, :pointer], :uint
  end
end

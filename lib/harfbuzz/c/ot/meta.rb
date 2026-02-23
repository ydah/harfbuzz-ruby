# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_meta_get_entry_tags,
      [:hb_face_t, :uint, :pointer, :pointer], :uint
    attach_function :hb_ot_meta_reference_entry,
      [:hb_face_t, :hb_ot_meta_tag_t], :hb_blob_t
  end
end

# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_blob_create,
      [:pointer, :uint, :hb_memory_mode_t, :pointer, :pointer], :hb_blob_t
    attach_function :hb_blob_create_from_file, [:string], :hb_blob_t
    attach_function :hb_blob_create_from_file_or_fail, [:string], :hb_blob_t
    attach_function :hb_blob_create_sub_blob, [:hb_blob_t, :uint, :uint], :hb_blob_t
    attach_function :hb_blob_copy_writable_or_fail, [:hb_blob_t], :hb_blob_t
    attach_function :hb_blob_get_empty, [], :hb_blob_t
    attach_function :hb_blob_destroy, [:hb_blob_t], :void
    attach_function :hb_blob_reference, [:hb_blob_t], :hb_blob_t
    attach_function :hb_blob_get_length, [:hb_blob_t], :uint
    attach_function :hb_blob_get_data, [:hb_blob_t, :pointer], :pointer
    attach_function :hb_blob_get_data_writable, [:hb_blob_t, :pointer], :pointer
    attach_function :hb_blob_is_immutable, [:hb_blob_t], :hb_bool_t
    attach_function :hb_blob_make_immutable, [:hb_blob_t], :void
    attach_function :hb_blob_set_user_data,
      [:hb_blob_t, :pointer, :pointer, :pointer, :hb_bool_t], :hb_bool_t
    attach_function :hb_blob_get_user_data, [:hb_blob_t, :pointer], :pointer
  end
end

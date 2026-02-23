# frozen_string_literal: true

module HarfBuzz
  module Subset
    # Subset C bindings loaded from libharfbuzz-subset
    module C
      extend FFI::Library

      SUBSET_LIBRARY_NAMES = %w[
        harfbuzz-subset libharfbuzz-subset libharfbuzz-subset-0
      ].freeze

      begin
        ffi_lib SUBSET_LIBRARY_NAMES
        @available = true
      rescue FFI::NotFoundError
        @available = false
      end

      def self.available?
        @available
      end

      if @available
        attach_function :hb_subset_input_create_or_fail, [], :pointer
        attach_function :hb_subset_input_destroy, [:pointer], :void
        attach_function :hb_subset_input_reference, [:pointer], :pointer
        attach_function :hb_subset_input_unicode_set, [:pointer], HarfBuzz::C.find_type(:hb_set_t)
        attach_function :hb_subset_input_glyph_set, [:pointer], HarfBuzz::C.find_type(:hb_set_t)
        attach_function :hb_subset_input_set_flags, [:pointer, :uint32], :void
        attach_function :hb_subset_input_get_flags, [:pointer], :uint32
        attach_function :hb_subset_or_fail,
          [HarfBuzz::C.find_type(:hb_face_t), :pointer], HarfBuzz::C.find_type(:hb_face_t)
        attach_function :hb_subset_plan_create_or_fail,
          [HarfBuzz::C.find_type(:hb_face_t), :pointer], :pointer
        attach_function :hb_subset_plan_destroy, [:pointer], :void
        attach_function :hb_subset_plan_reference, [:pointer], :pointer
        attach_function :hb_subset_plan_execute_or_fail,
          [:pointer], HarfBuzz::C.find_type(:hb_face_t)
        attach_function :hb_subset_plan_old_to_new_glyph_mapping,
          [:pointer], HarfBuzz::C.find_type(:hb_map_t)
        attach_function :hb_subset_plan_new_to_old_glyph_mapping,
          [:pointer], HarfBuzz::C.find_type(:hb_map_t)
        attach_function :hb_subset_plan_unicode_to_old_glyph_mapping,
          [:pointer], HarfBuzz::C.find_type(:hb_map_t)
      end
    end
  end
end

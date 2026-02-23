# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Meta table API
    module Meta
      module_function

      # Returns the tags of all meta table entries
      # @param face [Face] Font face
      # @return [Array<Integer>] Entry tags
      def entry_tags(face)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_ot_meta_get_entry_tags(face.ptr, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        tags_ptr = FFI::MemoryPointer.new(:uint32, count)
        count_ptr.write_uint(count)
        C.hb_ot_meta_get_entry_tags(face.ptr, 0, count_ptr, tags_ptr)
        tags_ptr.read_array_of_uint32(count_ptr.read_uint)
      end

      # Returns the blob for a meta entry
      # @param face [Face] Font face
      # @param tag [Symbol] Entry tag (:design_languages or :supported_languages)
      # @return [Blob] Entry data blob
      def entry(face, tag)
        Blob.wrap_owned(C.hb_ot_meta_reference_entry(face.ptr, tag))
      end
    end
  end
end

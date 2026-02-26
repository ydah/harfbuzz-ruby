# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Name table API
    module Name
      module_function

      # Returns all name entries from the name table
      # @param face [Face] Font face
      # @return [Array<C::HbOtNameEntryT>] Name entries
      def list(face)
        count_ptr = FFI::MemoryPointer.new(:uint)
        entries_ptr = C.hb_ot_name_list_names(face.ptr, count_ptr)
        count = count_ptr.read_uint
        return [] if count.zero? || entries_ptr.null?

        count.times.map { |i| C::HbOtNameEntryT.new(entries_ptr + i * C::HbOtNameEntryT.size) }
      end

      # Returns a name as a UTF-8 string
      # @param face [Face] Font face
      # @param name_id [Integer] Name ID
      # @param language [FFI::Pointer, nil] Language pointer (nil = default)
      # @return [String, nil] Name string or nil if not found
      def get_utf8(face, name_id, language = nil)
        lang = language || C.hb_language_get_default
        buf_size = FFI::MemoryPointer.new(:uint)
        buf_size.write_uint(0)
        C.hb_ot_name_get_utf8(face.ptr, name_id, lang, buf_size, nil)
        size = buf_size.read_uint
        return nil if size.zero?

        buf = FFI::MemoryPointer.new(:char, size + 1)
        buf_size.write_uint(size + 1)
        C.hb_ot_name_get_utf8(face.ptr, name_id, lang, buf_size, buf)
        buf.read_string(size)
      end

      # Returns a name as a UTF-16 encoded string
      # @param face [Face] Font face
      # @param name_id [Integer] Name ID
      # @param language [FFI::Pointer, nil] Language pointer (nil = default)
      # @return [String, nil] UTF-16LE encoded string or nil if not found
      def get_utf16(face, name_id, language = nil)
        lang = language || C.hb_language_get_default
        buf_size = FFI::MemoryPointer.new(:uint)
        buf_size.write_uint(0)
        C.hb_ot_name_get_utf16(face.ptr, name_id, lang, buf_size, nil)
        size = buf_size.read_uint
        return nil if size.zero?

        buf = FFI::MemoryPointer.new(:uint16, size + 1)
        buf_size.write_uint(size + 1)
        C.hb_ot_name_get_utf16(face.ptr, name_id, lang, buf_size, buf)
        actual = buf_size.read_uint
        buf.read_bytes(actual * 2).force_encoding("UTF-16LE")
      end

      # Returns a name as a UTF-32 encoded string
      # @param face [Face] Font face
      # @param name_id [Integer] Name ID
      # @param language [FFI::Pointer, nil] Language pointer (nil = default)
      # @return [String, nil] UTF-32LE encoded string or nil if not found
      def get_utf32(face, name_id, language = nil)
        lang = language || C.hb_language_get_default
        buf_size = FFI::MemoryPointer.new(:uint)
        buf_size.write_uint(0)
        C.hb_ot_name_get_utf32(face.ptr, name_id, lang, buf_size, nil)
        size = buf_size.read_uint
        return nil if size.zero?

        buf = FFI::MemoryPointer.new(:uint32, size + 1)
        buf_size.write_uint(size + 1)
        C.hb_ot_name_get_utf32(face.ptr, name_id, lang, buf_size, buf)
        actual = buf_size.read_uint
        buf.read_bytes(actual * 4).force_encoding("UTF-32LE")
      end
    end
  end
end

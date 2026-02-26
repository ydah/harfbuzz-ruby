# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_blob_t — binary data container
  class Blob
    attr_reader :ptr

    # Creates a Blob from binary data
    # @param data [String] Binary data
    # @param mode [Symbol] Memory mode (:duplicate, :readonly, :writable,
    #   :readonly_may_make_writable)
    # @return [Blob]
    def initialize(data, mode: :duplicate)
      mem = FFI::MemoryPointer.from_string(data)
      @ptr = C.hb_blob_create(mem, data.bytesize, mode, nil, nil)
      raise AllocationError, "Failed to create blob" if @ptr.null?

      # Keep mem alive until the blob is destroyed
      @mem = mem
      register_finalizer
    end

    # Creates a Blob from a file path. Returns an empty blob if file is missing.
    # @param path [String] File path
    # @return [Blob]
    def self.from_file(path)
      ptr = C.hb_blob_create_from_file(path)
      wrap_owned(ptr)
    end

    # Creates a Blob from a file path. Raises if the file cannot be read.
    # @param path [String] File path
    # @return [Blob]
    # @raise [AllocationError] If file cannot be read
    def self.from_file!(path)
      ptr = C.hb_blob_create_from_file_or_fail(path)
      raise AllocationError, "Failed to create blob from file: #{path}" if ptr.null?

      wrap_owned(ptr)
    end

    # Returns the empty (singleton) blob
    # @return [Blob]
    def self.empty
      wrap_borrowed(C.hb_blob_get_empty)
    end

    # Creates a sub-blob of this blob
    # @param offset [Integer] Byte offset into the blob
    # @param length [Integer] Length in bytes
    # @return [Blob]
    def sub_blob(offset, length)
      ptr = C.hb_blob_create_sub_blob(@ptr, offset, length)
      self.class.wrap_owned(ptr)
    end

    # Returns a writable copy of this blob, or nil if it fails
    # @return [Blob, nil]
    def writable_copy
      ptr = C.hb_blob_copy_writable_or_fail(@ptr)
      return nil if ptr.null?

      self.class.wrap_owned(ptr)
    end

    # @return [Integer] Blob length in bytes
    def length
      C.hb_blob_get_length(@ptr)
    end

    alias size length

    # @return [String] Blob data as a Ruby String (read-only)
    def data
      length_ptr = FFI::MemoryPointer.new(:uint)
      data_ptr = C.hb_blob_get_data(@ptr, length_ptr)
      return "".b if data_ptr.null?

      data_ptr.read_bytes(length_ptr.read_uint)
    end

    # @return [String, nil] Blob data as a writable Ruby String, or nil if blob is immutable
    def data_writable
      length_ptr = FFI::MemoryPointer.new(:uint)
      data_ptr = C.hb_blob_get_data_writable(@ptr, length_ptr)
      return nil if data_ptr.null?

      data_ptr.read_bytes(length_ptr.read_uint)
    end

    # @return [Boolean] true if the blob is immutable
    def immutable?
      C.from_hb_bool(C.hb_blob_is_immutable(@ptr))
    end

    # Makes the blob immutable
    # @return [self]
    def make_immutable!
      C.hb_blob_make_immutable(@ptr)
      self
    end

    def inspect
      "#<HarfBuzz::Blob length=#{length} immutable=#{immutable?}>"
    end

    # Wraps an owned pointer (will be destroyed via finalizer)
    def self.wrap_owned(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.send(:register_finalizer)
      obj
    end

    # Wraps a borrowed pointer (no finalizer — caller owns the lifetime)
    def self.wrap_borrowed(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.instance_variable_set(:@borrowed, true)
      obj
    end

    private

    def register_finalizer
      return if instance_variable_defined?(:@borrowed) && @borrowed

      HarfBuzz::Blob.define_finalizer(self, @ptr)
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_blob_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

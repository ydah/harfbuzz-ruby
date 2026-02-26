# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_face_t — a font face (font file + index)
  class Face
    attr_reader :ptr

    # Creates a Face from a Blob and face index
    # @param blob [Blob] Font data blob
    # @param index [Integer] Face index within the blob (0 for single-face fonts)
    def initialize(blob, index = 0)
      @blob = blob
      @ptr = C.hb_face_create(blob.ptr, index)
      raise AllocationError, "Failed to create face" if @ptr.null?

      register_finalizer
    end

    # Creates a Face with custom table access (callback-based)
    # @yield [tag] Called with the hb_tag_t for each table requested
    # @yieldreturn [Blob] Table blob
    # @return [Face]
    def self.for_tables(&block)
      callback_holder = []
      cb = FFI::Function.new(:pointer, [:pointer, :uint32, :pointer]) do |_face, tag, _user_data|
        blob = block.call(tag)
        blob ? blob.ptr : C.hb_blob_get_empty
      end
      callback_holder << cb

      ptr = C.hb_face_create_for_tables(cb, nil, nil)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.instance_variable_set(:@callback_holder, callback_holder)
      obj.send(:register_finalizer)
      obj
    end

    # Returns the singleton empty face
    # @return [Face]
    def self.empty
      wrap_borrowed(C.hb_face_get_empty)
    end

    # Returns the number of faces in a blob
    # @param blob [Blob] Font blob
    # @return [Integer] Face count
    def self.count(blob)
      C.hb_face_count(blob.ptr)
    end

    # @return [Integer] Face index
    def index
      C.hb_face_get_index(@ptr)
    end

    # @param idx [Integer] Face index
    def index=(idx)
      C.hb_face_set_index(@ptr, idx)
    end

    # @return [Integer] Units per em
    def upem
      C.hb_face_get_upem(@ptr)
    end

    # @param u [Integer] Units per em
    def upem=(u)
      C.hb_face_set_upem(@ptr, u)
    end

    # @return [Integer] Number of glyphs in this face
    def glyph_count
      C.hb_face_get_glyph_count(@ptr)
    end

    # @param count [Integer] Glyph count override
    def glyph_count=(count)
      C.hb_face_set_glyph_count(@ptr, count)
    end

    # @return [Array<Integer>] Array of table tags
    def table_tags
      # First call: pass count=0 to get total number of tables (return value)
      count_ptr = FFI::MemoryPointer.new(:uint)
      count_ptr.write_uint(0)
      total = C.hb_face_get_table_tags(@ptr, 0, count_ptr, nil)
      return [] if total.zero?

      tags_ptr = FFI::MemoryPointer.new(:uint32, total)
      count_ptr.write_uint(total)
      C.hb_face_get_table_tags(@ptr, 0, count_ptr, tags_ptr)
      actual = count_ptr.read_uint
      tags_ptr.read_array_of_uint32(actual)
    end

    # Returns the blob for a specific table
    # @param tag [Integer] OpenType table tag
    # @return [Blob] Table blob (owned)
    def table(tag)
      ptr = C.hb_face_reference_table(@ptr, tag)
      Blob.wrap_owned(ptr)
    end

    alias reference_table table

    # Returns the blob for the entire font face
    # @return [Blob] Face blob (owned)
    def blob
      ptr = C.hb_face_reference_blob(@ptr)
      Blob.wrap_owned(ptr)
    end

    # @return [Set] Set of all Unicode codepoints in this face
    def unicodes
      set = Set.new
      C.hb_face_collect_unicodes(@ptr, set.ptr)
      set
    end

    # @return [Map] Map from Unicode codepoints to nominal glyph IDs
    def nominal_glyph_mapping
      map = Map.new
      C.hb_face_collect_nominal_glyph_mapping(@ptr, map.ptr, FFI::Pointer::NULL)
      map
    end

    # @return [Set] Set of variation selector codepoints
    def variation_selectors
      set = Set.new
      C.hb_face_collect_variation_selectors(@ptr, set.ptr)
      set
    end

    # @param selector [Integer] Variation selector codepoint
    # @return [Set] Set of Unicode codepoints supported via the variation selector
    def variation_unicodes(selector)
      set = Set.new
      C.hb_face_collect_variation_unicodes(@ptr, selector, set.ptr)
      set
    end

    # @return [Boolean] true if face is immutable
    def immutable?
      C.from_hb_bool(C.hb_face_is_immutable(@ptr))
    end

    # Makes the face immutable (thread-safe to share after this)
    # @return [self]
    def make_immutable!
      C.hb_face_make_immutable(@ptr)
      self
    end

    def inspect
      "#<HarfBuzz::Face index=#{index} upem=#{upem} glyph_count=#{glyph_count}>"
    end

    def self.wrap_owned(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.send(:register_finalizer)
      obj
    end

    def self.wrap_borrowed(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.instance_variable_set(:@borrowed, true)
      obj
    end

    private

    def register_finalizer
      return if instance_variable_defined?(:@borrowed) && @borrowed

      HarfBuzz::Face.define_finalizer(self, @ptr)
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_face_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

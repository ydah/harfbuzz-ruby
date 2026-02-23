# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_buffer_t — text buffer for shaping
  class Buffer
    attr_reader :ptr

    # Creates a new empty buffer
    def initialize
      @ptr = C.hb_buffer_create
      raise AllocationError, "Failed to create buffer" if @ptr.null?

      register_finalizer
    end

    # Creates a buffer similar to this one (same properties, empty content)
    # @return [Buffer]
    def create_similar
      ptr = C.hb_buffer_create_similar(@ptr)
      self.class.wrap_owned(ptr)
    end

    # Returns the singleton empty buffer
    # @return [Buffer]
    def self.empty
      wrap_borrowed(C.hb_buffer_get_empty)
    end

    # Resets all buffer state
    # @return [self]
    def reset
      C.hb_buffer_reset(@ptr)
      self
    end

    # Clears text content but keeps properties
    # @return [self]
    def clear
      C.hb_buffer_clear_contents(@ptr)
      self
    end

    # Pre-allocates buffer capacity
    # @param size [Integer] Number of glyphs to pre-allocate
    # @return [Boolean] Success
    def pre_allocate(size)
      C.from_hb_bool(C.hb_buffer_pre_allocate(@ptr, size))
    end

    # @return [Boolean] true if last allocation was successful
    def allocation_successful?
      C.from_hb_bool(C.hb_buffer_allocation_successful(@ptr))
    end

    # Adds a single codepoint with cluster index
    # @param codepoint [Integer] Unicode codepoint
    # @param cluster [Integer] Cluster index
    # @return [self]
    def add(codepoint, cluster)
      C.hb_buffer_add(@ptr, codepoint, cluster)
      self
    end

    # Adds UTF-8 text to the buffer
    # @param text [String] Text to add (will be encoded as UTF-8)
    # @param item_offset [Integer] Offset into text (for cluster calculation)
    # @param item_length [Integer] Length (-1 = full text)
    # @return [self]
    def add_utf8(text, item_offset: 0, item_length: -1)
      encoded = text.encode("UTF-8")
      mem = FFI::MemoryPointer.from_string(encoded)
      C.hb_buffer_add_utf8(@ptr, mem, encoded.bytesize, item_offset, item_length)
      self
    end

    # Adds UTF-16 text to the buffer
    # @param text [String] Text (will be encoded as UTF-16LE)
    # @param item_offset [Integer] Offset in code units
    # @param item_length [Integer] Length in code units (-1 = full text)
    # @return [self]
    def add_utf16(text, item_offset: 0, item_length: -1)
      encoded = text.encode("UTF-16LE")
      mem = FFI::MemoryPointer.new(:uint16, encoded.bytesize / 2 + 1)
      mem.put_bytes(0, encoded)
      C.hb_buffer_add_utf16(@ptr, mem, encoded.bytesize / 2, item_offset, item_length)
      self
    end

    # Adds UTF-32 text to the buffer
    # @param text [String] Text (will be encoded as UTF-32LE)
    # @param item_offset [Integer] Offset in code units
    # @param item_length [Integer] Length in code units (-1 = full text)
    # @return [self]
    def add_utf32(text, item_offset: 0, item_length: -1)
      encoded = text.encode("UTF-32LE")
      mem = FFI::MemoryPointer.new(:uint32, encoded.bytesize / 4 + 1)
      mem.put_bytes(0, encoded)
      C.hb_buffer_add_utf32(@ptr, mem, encoded.bytesize / 4, item_offset, item_length)
      self
    end

    # Adds an array of Unicode codepoints to the buffer
    # @param codepoints [Array<Integer>] Array of Unicode codepoints
    # @param item_offset [Integer] Offset
    # @param item_length [Integer] Length (-1 = full array)
    # @return [self]
    def add_codepoints(codepoints, item_offset: 0, item_length: -1)
      mem = FFI::MemoryPointer.new(:uint32, codepoints.size)
      mem.put_array_of_uint32(0, codepoints)
      C.hb_buffer_add_codepoints(@ptr, mem, codepoints.size, item_offset, item_length)
      self
    end

    # Appends part of another buffer
    # @param other [Buffer] Source buffer
    # @param start [Integer] Start index
    # @param end_ [Integer] End index
    # @return [self]
    def append(other, start, end_)
      C.hb_buffer_append(@ptr, other.ptr, start, end_)
      self
    end

    # @return [Symbol] Content type (:invalid, :unicode, :glyphs)
    def content_type
      C.hb_buffer_get_content_type(@ptr)
    end

    # @param type [Symbol] Content type
    def content_type=(type)
      C.hb_buffer_set_content_type(@ptr, type)
    end

    # @return [Symbol] Buffer direction (:ltr, :rtl, :ttb, :btt, :invalid)
    def direction
      C.hb_buffer_get_direction(@ptr)
    end

    # @param dir [Symbol] Direction (:ltr, :rtl, :ttb, :btt)
    def direction=(dir)
      C.hb_buffer_set_direction(@ptr, dir)
    end

    # @return [Integer] Script (hb_script_t value)
    def script
      C.hb_buffer_get_script(@ptr)
    end

    # @param script [Integer] Script value
    def script=(script)
      C.hb_buffer_set_script(@ptr, script)
    end

    # @return [FFI::Pointer] Language pointer
    def language
      C.hb_buffer_get_language(@ptr)
    end

    # @param lang [FFI::Pointer] Language pointer (use HarfBuzz.language("en"))
    def language=(lang)
      C.hb_buffer_set_language(@ptr, lang)
    end

    # Guesses direction/script/language from buffer contents
    # @return [self]
    def guess_segment_properties
      C.hb_buffer_guess_segment_properties(@ptr)
      self
    end

    # @return [Integer] Buffer flags bitmask
    def flags
      C.hb_buffer_get_flags(@ptr)
    end

    # @param flags [Integer] Buffer flags bitmask
    def flags=(flags)
      C.hb_buffer_set_flags(@ptr, flags)
    end

    # @return [Symbol] Cluster level
    def cluster_level
      C.hb_buffer_get_cluster_level(@ptr)
    end

    # @param level [Symbol] Cluster level
    def cluster_level=(level)
      C.hb_buffer_set_cluster_level(@ptr, level)
    end

    # @return [Integer] Replacement codepoint for invalid input
    def replacement_codepoint
      C.hb_buffer_get_replacement_codepoint(@ptr)
    end

    # @param cp [Integer] Replacement codepoint
    def replacement_codepoint=(cp)
      C.hb_buffer_set_replacement_codepoint(@ptr, cp)
    end

    # @return [Integer] Invisible glyph ID
    def invisible_glyph
      C.hb_buffer_get_invisible_glyph(@ptr)
    end

    # @param glyph [Integer] Invisible glyph ID
    def invisible_glyph=(glyph)
      C.hb_buffer_set_invisible_glyph(@ptr, glyph)
    end

    # @return [Integer] Not-found glyph ID
    def not_found_glyph
      C.hb_buffer_get_not_found_glyph(@ptr)
    end

    # @param glyph [Integer] Not-found glyph ID
    def not_found_glyph=(glyph)
      C.hb_buffer_set_not_found_glyph(@ptr, glyph)
    end

    # @return [Integer] Random state
    def random_state
      C.hb_buffer_get_random_state(@ptr)
    end

    # @param state [Integer] Random state
    def random_state=(state)
      C.hb_buffer_set_random_state(@ptr, state)
    end

    # @return [Integer] Number of items in buffer
    def length
      C.hb_buffer_get_length(@ptr)
    end

    alias size length

    # @param len [Integer] New buffer length
    def length=(len)
      C.hb_buffer_set_length(@ptr, len)
    end

    # @return [Array<GlyphInfo>] Array of glyph info structs
    def glyph_infos
      length_ptr = FFI::MemoryPointer.new(:uint)
      infos_ptr = C.hb_buffer_get_glyph_infos(@ptr, length_ptr)
      count = length_ptr.read_uint
      return [] if infos_ptr.null? || count.zero?

      count.times.map do |i|
        GlyphInfo.new(infos_ptr + (i * C::HbGlyphInfoT.size))
      end
    end

    # @return [Array<GlyphPosition>] Array of glyph position structs
    def glyph_positions
      length_ptr = FFI::MemoryPointer.new(:uint)
      positions_ptr = C.hb_buffer_get_glyph_positions(@ptr, length_ptr)
      count = length_ptr.read_uint
      return [] if positions_ptr.null? || count.zero?

      count.times.map do |i|
        GlyphPosition.new(positions_ptr + (i * C::HbGlyphPositionT.size))
      end
    end

    # @return [Boolean] true if the buffer has glyph position data
    def has_positions?
      C.from_hb_bool(C.hb_buffer_has_positions(@ptr))
    end

    # Normalizes glyph clusters
    # @return [self]
    def normalize_glyphs
      C.hb_buffer_normalize_glyphs(@ptr)
      self
    end

    # Reverses buffer contents
    # @return [self]
    def reverse
      C.hb_buffer_reverse(@ptr)
      self
    end

    # Reverses a range of buffer contents
    # @param start [Integer] Start index
    # @param end_ [Integer] End index
    # @return [self]
    def reverse_range(start, end_)
      C.hb_buffer_reverse_range(@ptr, start, end_)
      self
    end

    # Reverses clusters
    # @return [self]
    def reverse_clusters
      C.hb_buffer_reverse_clusters(@ptr)
      self
    end

    # Computes difference flags between this buffer and another
    # @param other [Buffer] Buffer to compare against
    # @param dottedcircle_glyph [Integer] Dotted circle glyph ID
    # @param position_fuzz [Integer] Position comparison tolerance
    # @return [Integer] Difference flags bitmask
    def diff(other, dottedcircle_glyph, position_fuzz)
      C.hb_buffer_diff(@ptr, other.ptr, dottedcircle_glyph, position_fuzz)
    end

    # Serializes shaped glyphs to a string representation
    # @param font [Font, nil] Font used for glyph names (optional)
    # @param format [Symbol] Serialize format (:text or :json), defaults to :text
    # @param flags [Integer] Serialize flags (0 = default)
    # @return [String] Serialized glyph data
    def serialize_glyphs(font: nil, format: :text, flags: 0)
      buf_size = 4096
      buf = FFI::MemoryPointer.new(:char, buf_size)
      written_ptr = FFI::MemoryPointer.new(:uint)
      font_ptr = font ? font.ptr : FFI::Pointer::NULL
      C.hb_buffer_serialize_glyphs(@ptr, 0, length, buf, buf_size, written_ptr, font_ptr, format, flags)
      buf.read_string(written_ptr.read_uint)
    end

    def inspect
      "#<HarfBuzz::Buffer length=#{length} direction=#{direction} content_type=#{content_type}>"
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

      HarfBuzz::Buffer.define_finalizer(self, @ptr)
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_buffer_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

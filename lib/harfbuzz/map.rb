# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_map_t — an integer-to-integer mapping
  #
  # Behaves similarly to Ruby's Hash with Integer keys and values.
  # Includes Enumerable.
  class Map
    include Enumerable

    HB_MAP_VALUE_INVALID = 0xFFFFFFFF

    attr_reader :ptr

    def initialize
      @ptr = C.hb_map_create
      raise AllocationError, "Failed to create map" if @ptr.null?

      HarfBuzz::Map.define_finalizer(self, @ptr)
    end

    # Returns the singleton empty map
    # @return [Map]
    def self.empty
      wrap_borrowed(C.hb_map_get_empty)
    end

    # @return [Integer] Number of entries
    def size
      C.hb_map_get_population(@ptr)
    end

    alias length size

    # @return [Boolean] true if empty
    def empty?
      C.from_hb_bool(C.hb_map_is_empty(@ptr))
    end

    # @param key [Integer] Key
    # @return [Boolean] true if key exists
    def has_key?(key)
      C.from_hb_bool(C.hb_map_has(@ptr, key))
    end

    alias include? has_key?
    alias key? has_key?

    # @param key [Integer] Key
    # @return [Integer] Value (HB_MAP_VALUE_INVALID if not found)
    def [](key)
      val = C.hb_map_get(@ptr, key)
      val == HB_MAP_VALUE_INVALID ? nil : val
    end

    # @param key [Integer] Key
    # @param value [Integer] Value
    def []=(key, value)
      C.hb_map_set(@ptr, key, value)
    end

    # Deletes a key
    # @param key [Integer] Key to delete
    def delete(key)
      C.hb_map_del(@ptr, key)
    end

    # Clears all entries
    # @return [self]
    def clear
      C.hb_map_clear(@ptr)
      self
    end

    # @param other [Map] Map to compare
    # @return [Boolean] true if equal
    def ==(other)
      return false unless other.is_a?(Map)

      C.from_hb_bool(C.hb_map_is_equal(@ptr, other.ptr))
    end

    # @return [Integer] Hash of this map
    def hash
      C.hb_map_hash(@ptr)
    end

    # Copies entries from another map into this one
    # @param other [Map] Source map
    # @return [self]
    def update(other)
      C.hb_map_update(@ptr, other.ptr)
      self
    end

    alias merge! update

    # @return [Boolean] true if the last allocation was successful
    def allocation_successful?
      C.from_hb_bool(C.hb_map_allocation_successful(@ptr))
    end

    # @return [Set] Set of all keys
    def keys
      set = Set.new
      C.hb_map_keys(@ptr, set.ptr)
      set
    end

    # @return [Set] Set of all values
    def values
      set = Set.new
      C.hb_map_values(@ptr, set.ptr)
      set
    end

    # Iterates over key-value pairs
    # @yield [key, value]
    # @return [Enumerator] if no block given
    def each
      return to_enum(:each) unless block_given?

      idx_ptr = FFI::MemoryPointer.new(:int)
      idx_ptr.write_int(-1)
      key_ptr = FFI::MemoryPointer.new(:uint32)
      val_ptr = FFI::MemoryPointer.new(:uint32)

      while C.from_hb_bool(C.hb_map_next(@ptr, idx_ptr, key_ptr, val_ptr))
        yield key_ptr.read_uint32, val_ptr.read_uint32
      end
      self
    end

    def inspect
      "#<HarfBuzz::Map size=#{size}>"
    end

    def self.wrap_owned(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      define_finalizer(obj, ptr)
      obj
    end

    def self.wrap_borrowed(ptr)
      obj = allocate
      obj.instance_variable_set(:@ptr, ptr)
      obj.instance_variable_set(:@borrowed, true)
      obj
    end

    def self.define_finalizer(obj, ptr)
      destroy = C.method(:hb_map_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

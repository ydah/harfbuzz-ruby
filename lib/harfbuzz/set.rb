# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_set_t — a set of Unicode codepoints or glyph IDs
  #
  # Includes Enumerable for Ruby-friendly iteration.
  class Set
    include Enumerable

    HB_SET_VALUE_INVALID = C::HB_SET_VALUE_INVALID

    attr_reader :ptr

    def initialize
      @ptr = C.hb_set_create
      raise AllocationError, "Failed to create set" if @ptr.null?

      HarfBuzz::Set.define_finalizer(self, @ptr)
    end

    # Returns the singleton empty set
    # @return [Set]
    def self.empty
      wrap_borrowed(C.hb_set_get_empty)
    end

    # @return [Integer] Number of elements
    def size
      C.hb_set_get_population(@ptr)
    end

    alias length size

    # @return [Boolean] true if empty
    def empty?
      C.from_hb_bool(C.hb_set_is_empty(@ptr))
    end

    # @param value [Integer] Codepoint to check
    # @return [Boolean] true if value is in the set
    def include?(value)
      C.from_hb_bool(C.hb_set_has(@ptr, value))
    end

    alias member? include?

    # Adds a value to the set
    # @param value [Integer] Codepoint to add
    # @return [self]
    def add(value)
      C.hb_set_add(@ptr, value)
      self
    end

    alias << add

    # Adds a range of values (inclusive)
    # @param first [Integer] First codepoint
    # @param last [Integer] Last codepoint
    # @return [self]
    def add_range(first, last)
      C.hb_set_add_range(@ptr, first, last)
      self
    end

    # Adds a sorted array of codepoints
    # @param arr [Array<Integer>] Sorted array of codepoints
    # @return [self]
    def add_sorted_array(arr)
      mem = FFI::MemoryPointer.new(:uint32, arr.size)
      mem.put_array_of_uint32(0, arr)
      C.hb_set_add_sorted_array(@ptr, mem, arr.size)
      self
    end

    # Removes a value
    # @param value [Integer] Codepoint to remove
    # @return [self]
    def delete(value)
      C.hb_set_del(@ptr, value)
      self
    end

    # Removes a range of values (inclusive)
    # @param first [Integer] First codepoint
    # @param last [Integer] Last codepoint
    # @return [self]
    def delete_range(first, last)
      C.hb_set_del_range(@ptr, first, last)
      self
    end

    # Clears all values
    # @return [self]
    def clear
      C.hb_set_clear(@ptr)
      self
    end

    # @param other [Set] Set to compare
    # @return [Boolean] true if equal
    def ==(other)
      return false unless other.is_a?(Set)

      C.from_hb_bool(C.hb_set_is_equal(@ptr, other.ptr))
    end

    # @return [Integer] Hash of this set
    def hash
      C.hb_set_hash(@ptr)
    end

    # @param other [Set] Potential superset
    # @return [Boolean] true if self is a subset of other
    def subset?(other)
      C.from_hb_bool(C.hb_set_is_subset(@ptr, other.ptr))
    end

    # Replaces contents with another set
    # @param other [Set] Source set
    # @return [self]
    def replace(other)
      C.hb_set_set(@ptr, other.ptr)
      self
    end

    # Adds all elements from another set (in-place union)
    # @param other [Set] Set to union with
    # @return [self]
    def union(other)
      result = dup_set
      C.hb_set_union(result.ptr, other.ptr)
      result
    end

    alias | union

    # Removes all elements not in another set (in-place intersection)
    # @param other [Set] Set to intersect with
    # @return [self]
    def intersect(other)
      result = dup_set
      C.hb_set_intersect(result.ptr, other.ptr)
      result
    end

    alias & intersect

    # Removes all elements that are in another set (in-place subtraction)
    # @param other [Set] Set to subtract
    # @return [self]
    def subtract(other)
      result = dup_set
      C.hb_set_subtract(result.ptr, other.ptr)
      result
    end

    alias - subtract

    # Symmetric difference (elements in either but not both)
    # @param other [Set] Other set
    # @return [Set] New set
    def symmetric_difference(other)
      result = dup_set
      C.hb_set_symmetric_difference(result.ptr, other.ptr)
      result
    end

    alias ^ symmetric_difference

    # Inverts the set (complements it)
    # @return [self]
    def invert!
      C.hb_set_invert(@ptr)
      self
    end

    # @return [Integer, nil] Minimum value or nil if empty
    def min
      val = C.hb_set_get_min(@ptr)
      val == HB_SET_VALUE_INVALID ? nil : val
    end

    # @return [Integer, nil] Maximum value or nil if empty
    def max
      val = C.hb_set_get_max(@ptr)
      val == HB_SET_VALUE_INVALID ? nil : val
    end

    # Iterates over all values in ascending order
    # @yield [value]
    def each
      cp_ptr = FFI::MemoryPointer.new(:uint32)
      cp_ptr.write_uint32(HB_SET_VALUE_INVALID)
      yield cp_ptr.read_uint32 while C.from_hb_bool(C.hb_set_next(@ptr, cp_ptr))
    end

    # Iterates over all values in descending order
    # @yield [value]
    def reverse_each
      cp_ptr = FFI::MemoryPointer.new(:uint32)
      cp_ptr.write_uint32(HB_SET_VALUE_INVALID)
      yield cp_ptr.read_uint32 while C.from_hb_bool(C.hb_set_previous(@ptr, cp_ptr))
    end

    # Bulk-retrieves all values as an array
    # @return [Array<Integer>]
    def to_a
      return [] if empty?

      count = size
      buf = FFI::MemoryPointer.new(:uint32, count)
      actual = C.hb_set_next_many(@ptr, HB_SET_VALUE_INVALID, buf, count)
      buf.read_array_of_uint32(actual)
    end

    def inspect
      "#<HarfBuzz::Set size=#{size}>"
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
      destroy = C.method(:hb_set_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end

    private

    def dup_set
      new_set = self.class.new
      C.hb_set_set(new_set.ptr, @ptr)
      new_set
    end
  end
end

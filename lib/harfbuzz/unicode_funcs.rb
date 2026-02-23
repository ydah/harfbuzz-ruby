# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_unicode_funcs_t — Unicode property callbacks
  class UnicodeFuncs
    attr_reader :ptr

    # Creates a new UnicodeFuncs, optionally inheriting from a parent
    # @param parent [UnicodeFuncs, nil] Parent funcs (nil = use default)
    def initialize(parent = nil)
      parent_ptr = parent ? parent.ptr : C.hb_unicode_funcs_get_default
      @ptr = C.hb_unicode_funcs_create(parent_ptr)
      raise AllocationError, "Failed to create unicode_funcs" if @ptr.null?

      HarfBuzz::UnicodeFuncs.define_finalizer(self, @ptr)
    end

    # Returns the default Unicode functions
    # @return [UnicodeFuncs]
    def self.default
      wrap_borrowed(C.hb_unicode_funcs_get_default)
    end

    # Returns the empty Unicode functions
    # @return [UnicodeFuncs]
    def self.empty
      wrap_borrowed(C.hb_unicode_funcs_get_empty)
    end

    # Returns the parent functions
    # @return [UnicodeFuncs]
    def parent
      self.class.wrap_borrowed(C.hb_unicode_funcs_get_parent(@ptr))
    end

    # @return [Boolean] true if immutable
    def immutable?
      C.from_hb_bool(C.hb_unicode_funcs_is_immutable(@ptr))
    end

    # Makes immutable
    # @return [self]
    def make_immutable!
      C.hb_unicode_funcs_make_immutable(@ptr)
      self
    end

    # Sets a custom general_category function
    # @yield [codepoint] Returns general category symbol
    def on_general_category(&block)
      @general_category_callback = block
      cb = FFI::Function.new(:int, [:pointer, :uint32, :pointer]) do |_ufuncs, cp, _user_data|
        result = block.call(cp)
        C::UnicodeGeneralCategory[result] || result
      end
      @general_category_ffi = cb
      C.hb_unicode_funcs_set_general_category_func(@ptr, cb, nil, nil)
    end

    # Sets a custom combining_class function
    # @yield [codepoint] Returns combining class integer
    def on_combining_class(&block)
      @combining_class_callback = block
      cb = FFI::Function.new(:uint, [:pointer, :uint32, :pointer]) do |_ufuncs, cp, _user_data|
        block.call(cp)
      end
      @combining_class_ffi = cb
      C.hb_unicode_funcs_set_combining_class_func(@ptr, cb, nil, nil)
    end

    # Sets a custom mirroring function
    # @yield [codepoint] Returns mirrored codepoint
    def on_mirroring(&block)
      @mirroring_callback = block
      cb = FFI::Function.new(:uint32, [:pointer, :uint32, :pointer]) do |_ufuncs, cp, _user_data|
        block.call(cp)
      end
      @mirroring_ffi = cb
      C.hb_unicode_funcs_set_mirroring_func(@ptr, cb, nil, nil)
    end

    # Sets a custom script function
    # @yield [codepoint] Returns script value
    def on_script(&block)
      @script_callback = block
      cb = FFI::Function.new(:uint32, [:pointer, :uint32, :pointer]) do |_ufuncs, cp, _user_data|
        block.call(cp)
      end
      @script_ffi = cb
      C.hb_unicode_funcs_set_script_func(@ptr, cb, nil, nil)
    end

    # Sets a custom compose function
    # @yield [a, b] Returns composed codepoint or nil
    def on_compose(&block)
      @compose_callback = block
      cb = FFI::Function.new(:int, [:pointer, :uint32, :uint32, :pointer, :pointer]) do
        |_ufuncs, a, b, ab_ptr, _user_data|
        result = block.call(a, b)
        if result
          ab_ptr.write_uint32(result)
          1
        else
          0
        end
      end
      @compose_ffi = cb
      C.hb_unicode_funcs_set_compose_func(@ptr, cb, nil, nil)
    end

    # Sets a custom decompose function
    # @yield [ab] Returns [a, b] array or nil
    def on_decompose(&block)
      @decompose_callback = block
      cb = FFI::Function.new(:int, [:pointer, :uint32, :pointer, :pointer, :pointer]) do
        |_ufuncs, ab, a_ptr, b_ptr, _user_data|
        result = block.call(ab)
        if result
          a_ptr.write_uint32(result[0])
          b_ptr.write_uint32(result[1])
          1
        else
          0
        end
      end
      @decompose_ffi = cb
      C.hb_unicode_funcs_set_decompose_func(@ptr, cb, nil, nil)
    end

    # Queries the general category of a codepoint
    # @param cp [Integer] Unicode codepoint
    # @return [Symbol] General category
    def general_category(cp)
      C.hb_unicode_general_category(@ptr, cp)
    end

    # Queries the combining class of a codepoint
    # @param cp [Integer] Unicode codepoint
    # @return [Integer] Combining class
    def combining_class(cp)
      C.hb_unicode_combining_class(@ptr, cp)
    end

    # Queries the mirror codepoint
    # @param cp [Integer] Unicode codepoint
    # @return [Integer] Mirrored codepoint (or same if no mirror)
    def mirroring(cp)
      C.hb_unicode_mirroring(@ptr, cp)
    end

    # Queries the script of a codepoint
    # @param cp [Integer] Unicode codepoint
    # @return [Integer] Script value
    def script(cp)
      C.hb_unicode_script(@ptr, cp)
    end

    # Composes two codepoints into one
    # @param a [Integer] First codepoint
    # @param b [Integer] Second codepoint
    # @return [Integer, nil] Composed codepoint or nil
    def compose(a, b)
      ab_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_unicode_compose(@ptr, a, b, ab_ptr)
      ok.zero? ? nil : ab_ptr.read_uint32
    end

    # Decomposes a codepoint into two
    # @param cp [Integer] Codepoint to decompose
    # @return [Array<Integer>, nil] [a, b] or nil
    def decompose(cp)
      a_ptr = FFI::MemoryPointer.new(:uint32)
      b_ptr = FFI::MemoryPointer.new(:uint32)
      ok = C.hb_unicode_decompose(@ptr, cp, a_ptr, b_ptr)
      ok.zero? ? nil : [a_ptr.read_uint32, b_ptr.read_uint32]
    end

    def inspect
      "#<HarfBuzz::UnicodeFuncs immutable=#{immutable?}>"
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
      destroy = C.method(:hb_unicode_funcs_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end
  end
end

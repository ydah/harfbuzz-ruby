# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_shape_plan_t — a cached shaping plan for repeated shaping
  class ShapePlan
    attr_reader :ptr

    # Creates a new ShapePlan for the given face and properties
    # @param face [Face] Font face
    # @param props [C::HbSegmentPropertiesT] Segment properties
    # @param features [Array<Feature>] Features
    # @param shapers [Array<String>, nil] Shaper list
    # @return [ShapePlan]
    def self.new(face, props, features = [], shapers: nil)
      features_ptr = HarfBuzz.send(:build_features_ptr, features)
      shapers_ptr = build_shapers_ptr(shapers)
      ptr = C.hb_shape_plan_create(
        face.ptr, props, features_ptr, features.size, shapers_ptr
      )
      wrap_owned(ptr)
    end

    # Creates (or retrieves from cache) a ShapePlan
    # @param face [Face] Font face
    # @param props [C::HbSegmentPropertiesT] Segment properties
    # @param features [Array<Feature>] Features
    # @param shapers [Array<String>, nil] Shaper list
    # @return [ShapePlan]
    def self.cached(face, props, features = [], shapers: nil)
      features_ptr = HarfBuzz.send(:build_features_ptr, features)
      shapers_ptr = build_shapers_ptr(shapers)
      ptr = C.hb_shape_plan_create_cached(
        face.ptr, props, features_ptr, features.size, shapers_ptr
      )
      wrap_owned(ptr)
    end

    # Returns the singleton empty shape plan
    # @return [ShapePlan]
    def self.empty
      wrap_borrowed(C.hb_shape_plan_get_empty)
    end

    # Executes the shape plan
    # @param font [Font] Font to use
    # @param buffer [Buffer] Buffer to shape
    # @param features [Array<Feature>] Features
    # @return [Boolean] Success
    def execute(font, buffer, features = [])
      features_ptr = HarfBuzz.send(:build_features_ptr, features)
      C.from_hb_bool(
        C.hb_shape_plan_execute(@ptr, font.ptr, buffer.ptr, features_ptr, features.size)
      )
    end

    # @return [String] Name of the shaper used
    def shaper
      C.hb_shape_plan_get_shaper(@ptr)
    end

    def inspect
      "#<HarfBuzz::ShapePlan shaper=#{shaper.inspect}>"
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
      destroy = C.method(:hb_shape_plan_destroy)
      ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
    end

    def self.build_shapers_ptr(shapers)
      return FFI::Pointer::NULL unless shapers

      ptrs = shapers.map { |s| FFI::MemoryPointer.from_string(s) }
      ptrs << FFI::Pointer::NULL
      arr = FFI::MemoryPointer.new(:pointer, ptrs.size)
      ptrs.each_with_index { |p, i| arr[i].put_pointer(0, p) }
      arr
    end
    private_class_method :build_shapers_ptr
  end
end

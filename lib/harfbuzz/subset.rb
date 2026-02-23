# frozen_string_literal: true

module HarfBuzz
  # Font subsetting API (requires libharfbuzz-subset)
  module Subset
    # @return [Boolean] true if libharfbuzz-subset is available
    def self.available?
      C.available?
    end

    # Subsets a font face using the given input specification
    # @param face [HarfBuzz::Face] Source font face
    # @param input [Input] Subset input specification
    # @return [HarfBuzz::Face] Subsetted face
    # @raise [UnavailableError] If subset library is not available
    # @raise [SubsetError] If subsetting fails
    def self.subset(face, input)
      raise UnavailableError, "libharfbuzz-subset is not available" unless available?

      ptr = C.hb_subset_or_fail(face.ptr, input.ptr)
      raise SubsetError, "Subsetting failed" if ptr.null?

      HarfBuzz::Face.wrap_owned(ptr)
    end

    # Wraps hb_subset_input_t — specifies what to include in a subset
    class Input
      attr_reader :ptr

      # Creates a new subset input
      # @raise [UnavailableError] If subset library is not available
      # @raise [AllocationError] If allocation fails
      def initialize
        raise UnavailableError, "libharfbuzz-subset is not available" unless C.available?

        @ptr = C.hb_subset_input_create_or_fail
        raise AllocationError, "Failed to create subset input" if @ptr.null?

        HarfBuzz::Subset::Input.define_finalizer(self, @ptr)
      end

      # Returns the set of Unicode codepoints to include (borrowed reference)
      # @return [HarfBuzz::Set] Unicode set (do not destroy separately)
      def unicode_set
        HarfBuzz::Set.wrap_borrowed(C.hb_subset_input_unicode_set(@ptr))
      end

      # Returns the set of glyph IDs to include (borrowed reference)
      # @return [HarfBuzz::Set] Glyph set (do not destroy separately)
      def glyph_set
        HarfBuzz::Set.wrap_borrowed(C.hb_subset_input_glyph_set(@ptr))
      end

      # @return [Integer] Current flags bitmask
      def flags
        C.hb_subset_input_get_flags(@ptr)
      end

      # @param flags [Integer] New flags bitmask
      def flags=(flags)
        C.hb_subset_input_set_flags(@ptr, flags)
      end

      def inspect
        "#<HarfBuzz::Subset::Input flags=#{flags}>"
      end

      def self.define_finalizer(obj, ptr)
        destroy = C.method(:hb_subset_input_destroy)
        ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
      end
    end

    # Wraps hb_subset_plan_t — a more fine-grained subsetting plan
    class Plan
      attr_reader :ptr

      # Creates a subset plan for a face using the given input
      # @param face [HarfBuzz::Face] Source font face
      # @param input [Input] Subset input specification
      # @raise [UnavailableError] If subset library is not available
      # @raise [SubsetError] If plan creation fails
      def initialize(face, input)
        raise UnavailableError, "libharfbuzz-subset is not available" unless C.available?

        @ptr = C.hb_subset_plan_create_or_fail(face.ptr, input.ptr)
        raise SubsetError, "Failed to create subset plan" if @ptr.null?

        HarfBuzz::Subset::Plan.define_finalizer(self, @ptr)
      end

      # Executes the plan and returns the subsetted face
      # @return [HarfBuzz::Face] Subsetted face
      # @raise [SubsetError] If execution fails
      def execute
        ptr = C.hb_subset_plan_execute_or_fail(@ptr)
        raise SubsetError, "Subset plan execution failed" if ptr.null?

        HarfBuzz::Face.wrap_owned(ptr)
      end

      # Returns the old→new glyph ID mapping (borrowed)
      # @return [HarfBuzz::Map]
      def old_to_new_glyph_mapping
        HarfBuzz::Map.wrap_borrowed(C.hb_subset_plan_old_to_new_glyph_mapping(@ptr))
      end

      # Returns the new→old glyph ID mapping (borrowed)
      # @return [HarfBuzz::Map]
      def new_to_old_glyph_mapping
        HarfBuzz::Map.wrap_borrowed(C.hb_subset_plan_new_to_old_glyph_mapping(@ptr))
      end

      # Returns the unicode→old glyph ID mapping (borrowed)
      # @return [HarfBuzz::Map]
      def unicode_to_old_glyph_mapping
        HarfBuzz::Map.wrap_borrowed(C.hb_subset_plan_unicode_to_old_glyph_mapping(@ptr))
      end

      def inspect
        "#<HarfBuzz::Subset::Plan>"
      end

      def self.define_finalizer(obj, ptr)
        destroy = C.method(:hb_subset_plan_destroy)
        ObjectSpace.define_finalizer(obj, proc { destroy.call(ptr) })
      end
    end
  end
end

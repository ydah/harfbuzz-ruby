# frozen_string_literal: true

module HarfBuzz
  module AAT
    # Apple Advanced Typography Layout queries
    module Layout
      module_function

      # @param face [Face] Font face
      # @return [Boolean] true if the face has AAT morx substitution
      def has_substitution?(face)
        C.from_hb_bool(C.hb_aat_layout_has_substitution(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if the face has AAT kerning/kerx positioning
      def has_positioning?(face)
        C.from_hb_bool(C.hb_aat_layout_has_positioning(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Boolean] true if the face has AAT trak tracking
      def has_tracking?(face)
        C.from_hb_bool(C.hb_aat_layout_has_tracking(face.ptr))
      end

      # Returns feature types available in the AAT 'feat' table
      # @param face [Face] Font face
      # @return [Array<Integer>] Feature type values
      def feature_types(face)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_aat_layout_get_feature_types(face.ptr, 0, count_ptr, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        types_ptr = FFI::MemoryPointer.new(:uint, count)
        count_ptr.write_uint(count)
        C.hb_aat_layout_get_feature_types(face.ptr, 0, count_ptr, types_ptr)
        types_ptr.read_array_of_uint(count_ptr.read_uint)
      end

      # Returns the name ID for a feature type
      # @param face [Face] Font face
      # @param type [Integer] Feature type
      # @return [Integer, nil] Name ID or nil
      def feature_type_name_id(face, type)
        name_id_ptr = FFI::MemoryPointer.new(:uint)
        ok = C.hb_aat_layout_feature_type_get_name_id(face.ptr, type, name_id_ptr)
        ok.zero? ? nil : name_id_ptr.read_uint
      end

      # Returns the selector infos for a feature type
      # @param face [Face] Font face
      # @param type [Integer] Feature type
      # @return [Array<C::HbAatLayoutFeatureSelectorInfoT>] Selector info array
      def selector_infos(face, type)
        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(0)
        C.hb_aat_layout_feature_type_get_selector_infos(face.ptr, type, 0, count_ptr, nil, nil)
        count = count_ptr.read_uint
        return [] if count.zero?

        infos_ptr = FFI::MemoryPointer.new(C::HbAatLayoutFeatureSelectorInfoT, count)
        count_ptr.write_uint(count)
        C.hb_aat_layout_feature_type_get_selector_infos(
          face.ptr, type, 0, count_ptr, infos_ptr, nil
        )
        actual = count_ptr.read_uint
        actual.times.map do |i|
          C::HbAatLayoutFeatureSelectorInfoT.new(
            infos_ptr + i * C::HbAatLayoutFeatureSelectorInfoT.size
          )
        end
      end
    end
  end
end

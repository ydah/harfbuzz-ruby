# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Variable Fonts API
    module Var
      module_function

      # @param face [Face] Font face
      # @return [Boolean] true if the face has variation data
      def has_data?(face)
        C.from_hb_bool(C.hb_ot_var_has_data(face.ptr))
      end

      # @param face [Face] Font face
      # @return [Integer] Number of variation axes
      def axis_count(face)
        C.hb_ot_var_get_axis_count(face.ptr)
      end

      # Returns information about all variation axes
      # @param face [Face] Font face
      # @return [Array<C::HbOtVarAxisInfoT>] Axis info array
      def axis_infos(face)
        count = axis_count(face)
        return [] if count.zero?

        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(count)
        infos_ptr = FFI::MemoryPointer.new(C::HbOtVarAxisInfoT, count)
        C.hb_ot_var_get_axis_infos(face.ptr, 0, count_ptr, infos_ptr)
        actual = count_ptr.read_uint
        actual.times.map { |i| C::HbOtVarAxisInfoT.new(infos_ptr + i * C::HbOtVarAxisInfoT.size) }
      end

      # Finds a specific axis by tag
      # @param face [Face] Font face
      # @param tag [Integer] Axis tag (e.g., HarfBuzz.tag("wght"))
      # @return [C::HbOtVarAxisInfoT, nil] Axis info or nil
      def find_axis_info(face, tag)
        info = C::HbOtVarAxisInfoT.new
        ok = C.hb_ot_var_find_axis_info(face.ptr, tag, info)
        ok.zero? ? nil : info
      end

      # @param face [Face] Font face
      # @return [Integer] Number of named instances
      def named_instance_count(face)
        C.hb_ot_var_get_named_instance_count(face.ptr)
      end

      # @param face [Face] Font face
      # @param idx [Integer] Instance index
      # @return [Integer] Name ID for the subfamily name
      def named_instance_subfamily_name_id(face, idx)
        C.hb_ot_var_named_instance_get_subfamily_name_id(face.ptr, idx)
      end

      # @param face [Face] Font face
      # @param idx [Integer] Instance index
      # @return [Integer] Name ID for the PostScript name
      def named_instance_postscript_name_id(face, idx)
        C.hb_ot_var_named_instance_get_postscript_name_id(face.ptr, idx)
      end

      # Returns design coordinates for a named instance
      # @param face [Face] Font face
      # @param idx [Integer] Instance index
      # @return [Array<Float>] Design coordinates
      def named_instance_design_coords(face, idx)
        count = axis_count(face)
        return [] if count.zero?

        count_ptr = FFI::MemoryPointer.new(:uint)
        count_ptr.write_uint(count)
        coords_ptr = FFI::MemoryPointer.new(:float, count)
        C.hb_ot_var_named_instance_get_design_coords(face.ptr, idx, count_ptr, coords_ptr)
        coords_ptr.read_array_of_float(count_ptr.read_uint)
      end

      # Normalizes variation axis values
      # @param face [Face] Font face
      # @param variations [Array<Variation>] Design-space variation values
      # @return [Array<Integer>] Normalized coordinates
      def normalize_variations(face, variations)
        count = C.hb_ot_var_get_axis_count(face.ptr)
        return [] if count.zero?

        var_structs = variations.map(&:to_struct)
        var_ptr = FFI::MemoryPointer.new(C::HbVariationT, variations.size)
        var_structs.each_with_index do |s, i|
          var_ptr.put_bytes(i * C::HbVariationT.size,
                            s.to_ptr.read_bytes(C::HbVariationT.size))
        end
        coords_ptr = FFI::MemoryPointer.new(:int32, count)
        C.hb_ot_var_normalize_variations(face.ptr, var_ptr, variations.size, coords_ptr, count)
        coords_ptr.read_array_of_int32(count)
      end

      # Normalizes design-space coordinates to normalized space
      # @param face [Face] Font face
      # @param coords [Array<Float>] Design coordinates
      # @return [Array<Integer>] Normalized coordinates
      def normalize_coords(face, coords)
        count = axis_count(face)
        return [] if count.zero?

        in_ptr = FFI::MemoryPointer.new(:float, coords.size)
        in_ptr.put_array_of_float(0, coords)
        out_ptr = FFI::MemoryPointer.new(:int32, count)
        C.hb_ot_var_normalize_coords(face.ptr, coords.size, in_ptr, out_ptr)
        out_ptr.read_array_of_int32(count)
      end
    end
  end
end

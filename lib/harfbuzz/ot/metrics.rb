# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Metrics API
    module Metrics
      module_function

      # Returns a metric position value (returns nil if not available)
      # @param font [Font] Sized font
      # @param tag [Integer] Metric tag
      # @return [Integer, nil] Position or nil
      def position(font, tag)
        pos_ptr = FFI::MemoryPointer.new(:int32)
        ok = C.hb_ot_metrics_get_position(font.ptr, tag, pos_ptr)
        ok.zero? ? nil : pos_ptr.read_int32
      end

      # Returns a metric position with fallback (always returns a value)
      # @param font [Font] Sized font
      # @param tag [Integer] Metric tag
      # @return [Integer] Position
      def position_with_fallback(font, tag)
        pos_ptr = FFI::MemoryPointer.new(:int32)
        C.hb_ot_metrics_get_position_with_fallback(font.ptr, tag, pos_ptr)
        pos_ptr.read_int32
      end

      # Returns a metric float variation value
      # @param font [Font] Sized font
      # @param tag [Integer] Metric tag
      # @return [Float] Variation value
      def variation(font, tag)
        C.hb_ot_metrics_get_variation(font.ptr, tag)
      end

      # Returns the X variation for a metric
      # @param font [Font] Sized font
      # @param tag [Integer] Metric tag
      # @return [Integer] X variation
      def x_variation(font, tag)
        C.hb_ot_metrics_get_x_variation(font.ptr, tag)
      end

      # Returns the Y variation for a metric
      # @param font [Font] Sized font
      # @param tag [Integer] Metric tag
      # @return [Integer] Y variation
      def y_variation(font, tag)
        C.hb_ot_metrics_get_y_variation(font.ptr, tag)
      end
    end
  end
end

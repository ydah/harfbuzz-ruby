# frozen_string_literal: true

module HarfBuzz
  # Represents an OpenType variation axis value (e.g., "wght=700")
  class Variation
    def initialize(struct)
      @struct = struct
    end

    # @return [Integer] Variation axis tag as uint32
    def tag
      @struct[:tag]
    end

    # @return [Float] Variation axis value
    def value
      @struct[:value]
    end

    # Parses a variation string such as "wght=700" or "ital=1"
    # @param str [String] Variation string
    # @return [Variation] Parsed variation
    # @raise [VariationParseError] If the string cannot be parsed
    def self.from_string(str)
      struct = C::HbVariationT.new
      result = C.hb_variation_from_string(str, str.bytesize, struct)
      raise VariationParseError, "Invalid variation string: #{str.inspect}" if result.zero?

      new(struct)
    end

    # Returns the FFI struct for passing to C functions
    # @return [C::HbVariationT]
    def to_struct
      @struct
    end

    # @return [String] Variation string representation
    def to_s
      buf = FFI::MemoryPointer.new(:char, 64)
      C.hb_variation_to_string(@struct, buf, 64)
      buf.read_string
    end

    def inspect
      "#<HarfBuzz::Variation #{to_s}>"
    end
  end
end

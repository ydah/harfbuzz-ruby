# frozen_string_literal: true

module HarfBuzz
  # Represents an OpenType feature (e.g., "liga", "+kern", "smcp=1")
  class Feature
    HB_FEATURE_GLOBAL_START = 0
    HB_FEATURE_GLOBAL_END   = 0xFFFFFFFF

    def initialize(struct)
      @struct = struct
    end

    # @return [Integer] Feature tag as uint32
    def tag
      @struct[:tag]
    end

    # @return [Integer] Feature value
    def value
      @struct[:value]
    end

    # @return [Integer] Start index in buffer (HB_FEATURE_GLOBAL_START for global)
    def start
      @struct[:start]
    end

    # @return [Integer] End index in buffer (HB_FEATURE_GLOBAL_END for global)
    def end_index
      @struct[:end]
    end

    # Parses a feature string such as "liga", "+kern", "-calt", "smcp=1"
    # @param str [String] Feature string
    # @return [Feature] Parsed feature
    # @raise [FeatureParseError] If the string cannot be parsed
    def self.from_string(str)
      struct = C::HbFeatureT.new
      result = C.hb_feature_from_string(str, str.bytesize, struct)
      raise FeatureParseError, "Invalid feature string: #{str.inspect}" if result.zero?

      new(struct)
    end

    # Builds a list of Feature objects from a Hash
    # @param hash [Hash] Map of tag => value (true/false/Integer)
    # @return [Array<Feature>] List of features
    def self.from_hash(hash)
      hash.map do |tag, value|
        case value
        when true    then from_string("+#{tag}")
        when false   then from_string("-#{tag}")
        when Integer then from_string("#{tag}=#{value}")
        else raise InvalidArgumentError, "Unknown feature value: #{value.inspect}"
        end
      end
    end

    # Returns the FFI struct for passing to C functions
    # @return [C::HbFeatureT]
    def to_struct
      @struct
    end

    # @return [String] Feature string representation
    def to_s
      buf = FFI::MemoryPointer.new(:char, 128)
      C.hb_feature_to_string(@struct, buf, 128)
      buf.read_string
    end

    def inspect
      "#<HarfBuzz::Feature #{to_s}>"
    end
  end
end

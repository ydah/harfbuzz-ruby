# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_glyph_info_t, providing access to glyph ID and cluster index
  class GlyphInfo
    def initialize(struct_ptr)
      @struct = C::HbGlyphInfoT.new(struct_ptr)
    end

    # @return [Integer] Glyph ID (after shaping) or Unicode codepoint (before shaping)
    def codepoint
      @struct[:codepoint]
    end

    alias glyph_id codepoint

    # @return [Integer] Cluster index in source text
    def cluster
      @struct[:cluster]
    end

    # @return [Integer] Glyph flags bitmask
    def mask
      @struct[:mask]
    end

    def to_h
      { codepoint: codepoint, cluster: cluster, mask: mask }
    end

    def inspect
      "#<HarfBuzz::GlyphInfo glyph_id=#{codepoint} cluster=#{cluster}>"
    end
  end
end

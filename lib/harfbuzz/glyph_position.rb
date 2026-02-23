# frozen_string_literal: true

module HarfBuzz
  # Wraps hb_glyph_position_t, providing access to advance and offset values
  class GlyphPosition
    def initialize(struct_ptr)
      @struct = C::HbGlyphPositionT.new(struct_ptr)
    end

    # @return [Integer] Horizontal advance (in font units)
    def x_advance
      @struct[:x_advance]
    end

    # @return [Integer] Vertical advance (in font units)
    def y_advance
      @struct[:y_advance]
    end

    # @return [Integer] Horizontal offset (in font units)
    def x_offset
      @struct[:x_offset]
    end

    # @return [Integer] Vertical offset (in font units)
    def y_offset
      @struct[:y_offset]
    end

    def to_h
      {
        x_advance: x_advance, y_advance: y_advance,
        x_offset: x_offset, y_offset: y_offset
      }
    end

    def inspect
      "#<HarfBuzz::GlyphPosition adv=(#{x_advance},#{y_advance}) off=(#{x_offset},#{y_offset})>"
    end
  end
end

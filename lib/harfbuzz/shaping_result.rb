# frozen_string_literal: true

module HarfBuzz
  # Value object returned by HarfBuzz.shape_text — provides convenient access
  # to shaped glyphs, positions, and rendering helpers.
  class ShapingResult
    include Enumerable

    attr_reader :buffer, :font

    # @param buffer [Buffer] Shaped buffer
    # @param font [Font] Font used for shaping
    def initialize(buffer:, font:)
      @buffer = buffer
      @font = font
      @glyph_infos = buffer.glyph_infos
      @glyph_positions = buffer.glyph_positions
    end

    # @return [Array<GlyphInfo>] Glyph info array
    def glyph_infos
      @glyph_infos
    end

    # @return [Array<GlyphPosition>] Glyph position array
    def glyph_positions
      @glyph_positions
    end

    # Iterates over [GlyphInfo, GlyphPosition] pairs
    def each
      @glyph_infos.zip(@glyph_positions).each { |info, pos| yield info, pos }
    end

    # @return [Integer] Number of glyphs
    def length
      @glyph_infos.length
    end

    alias size length

    # Returns the total advance as [x_advance, y_advance]
    # @return [Array<Integer>]
    def total_advance
      @glyph_positions.inject([0, 0]) do |(x, y), pos|
        [x + pos.x_advance, y + pos.y_advance]
      end
    end

    # Generates an SVG path string for all glyphs at their shaped positions
    # @return [String] SVG path data
    def to_svg_path
      paths = []
      cx = 0
      cy = 0
      each do |info, pos|
        glyph_path = extract_glyph_path(info.glyph_id)
        ox = cx + pos.x_offset
        oy = cy + pos.y_offset
        paths << translate_path(glyph_path, ox, oy) unless glyph_path.empty?
        cx += pos.x_advance
        cy += pos.y_advance
      end
      paths.join(" ")
    end

    def inspect
      "#<HarfBuzz::ShapingResult length=#{length} total_advance=#{total_advance.inspect}>"
    end

    private

    def extract_glyph_path(glyph_id)
      segments = []
      draw = DrawFuncs.new
      draw.on_move_to    { |x, y| segments << "M#{x},#{y}" }
      draw.on_line_to    { |x, y| segments << "L#{x},#{y}" }
      draw.on_quadratic_to { |cx, cy, x, y| segments << "Q#{cx},#{cy},#{x},#{y}" }
      draw.on_cubic_to   { |c1x, c1y, c2x, c2y, x, y|
        segments << "C#{c1x},#{c1y},#{c2x},#{c2y},#{x},#{y}"
      }
      draw.on_close_path { segments << "Z" }
      draw.make_immutable!
      @font.draw_glyph(glyph_id, draw)
      segments.join
    end

    def translate_path(path, ox, oy)
      return path if ox.zero? && oy.zero?

      "translate(#{ox},#{oy}) #{path}"
    end
  end
end

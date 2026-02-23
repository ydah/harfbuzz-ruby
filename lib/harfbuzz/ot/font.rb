# frozen_string_literal: true

module HarfBuzz
  module OT
    # OpenType Font functions
    module Font
      module_function

      # Sets OpenType font functions on a font
      # @param font [HarfBuzz::Font] Font to configure
      def set_funcs(font)
        C.hb_ot_font_set_funcs(font.ptr)
      end
    end
  end
end

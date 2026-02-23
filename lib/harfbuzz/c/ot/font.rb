# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_font_set_funcs, [:hb_font_t], :void
  end
end

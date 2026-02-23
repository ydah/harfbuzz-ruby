# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_shape_glyphs_closure,
      [:hb_font_t, :hb_buffer_t, :pointer, :uint, :hb_set_t], :void
    attach_function :hb_ot_shape_plan_collect_lookups,
      [:hb_shape_plan_t, :hb_tag_t, :hb_set_t], :void
  end
end

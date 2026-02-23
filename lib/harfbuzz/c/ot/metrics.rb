# frozen_string_literal: true

module HarfBuzz
  module C
    attach_function :hb_ot_metrics_get_position,
      [:hb_font_t, :uint, :pointer], :hb_bool_t
    attach_function :hb_ot_metrics_get_position_with_fallback,
      [:hb_font_t, :uint, :pointer], :void
    attach_function :hb_ot_metrics_get_variation,
      [:hb_font_t, :uint], :float
    attach_function :hb_ot_metrics_get_x_variation,
      [:hb_font_t, :uint], :hb_position_t
    attach_function :hb_ot_metrics_get_y_variation,
      [:hb_font_t, :uint], :hb_position_t
  end
end

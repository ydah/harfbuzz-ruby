# frozen_string_literal: true

module HarfBuzz
  module C
    class HbGlyphInfoT < FFI::Struct
      layout :codepoint, :hb_codepoint_t,
             :mask,      :hb_mask_t,
             :cluster,   :uint32,
             :var1,      :uint32,
             :var2,      :uint32
    end

    class HbGlyphPositionT < FFI::Struct
      layout :x_advance, :hb_position_t,
             :y_advance, :hb_position_t,
             :x_offset,  :hb_position_t,
             :y_offset,  :hb_position_t,
             :var,       :uint32
    end

    class HbFeatureT < FFI::Struct
      layout :tag,   :hb_tag_t,
             :value, :uint32,
             :start, :uint,
             :end,   :uint
    end

    class HbVariationT < FFI::Struct
      layout :tag,   :hb_tag_t,
             :value, :float
    end

    class HbSegmentPropertiesT < FFI::Struct
      layout :direction, :int,
             :script,    :uint32,
             :language,  :pointer,
             :reserved1, :pointer,
             :reserved2, :pointer
    end

    class HbGlyphExtentsT < FFI::Struct
      layout :x_bearing, :hb_position_t,
             :y_bearing, :hb_position_t,
             :width,     :hb_position_t,
             :height,    :hb_position_t
    end

    class HbFontExtentsT < FFI::Struct
      layout :ascender,  :hb_position_t,
             :descender, :hb_position_t,
             :line_gap,  :hb_position_t,
             :reserved9, :hb_position_t,
             :reserved8, :hb_position_t,
             :reserved7, :hb_position_t,
             :reserved6, :hb_position_t,
             :reserved5, :hb_position_t,
             :reserved4, :hb_position_t,
             :reserved3, :hb_position_t,
             :reserved2, :hb_position_t,
             :reserved1, :hb_position_t
    end

    class HbOtVarAxisInfoT < FFI::Struct
      layout :axis_index,    :uint,
             :tag,           :hb_tag_t,
             :name_id,       :uint,
             :flags,         :uint,
             :min_value,     :float,
             :default_value, :float,
             :max_value,     :float,
             :reserved,      :uint
    end

    class HbOtNameEntryT < FFI::Struct
      layout :name_id,  :uint,
             :var,      :uint32,
             :language, :pointer
    end

    class HbOtMathGlyphVariantT < FFI::Struct
      layout :glyph,   :hb_codepoint_t,
             :advance, :hb_position_t
    end

    class HbOtMathGlyphPartT < FFI::Struct
      layout :glyph,                  :hb_codepoint_t,
             :start_connector_length, :hb_position_t,
             :end_connector_length,   :hb_position_t,
             :full_advance,           :hb_position_t,
             :flags,                  :uint
    end

    class HbOtColorLayerT < FFI::Struct
      layout :glyph,       :hb_codepoint_t,
             :color_index, :uint
    end

    class HbAatLayoutFeatureSelectorInfoT < FFI::Struct
      layout :name_id,  :uint,
             :enable,   :uint,
             :disable,  :uint,
             :reserved, :uint
    end

    class HbDrawStateT < FFI::Struct
      layout :path_open,    :hb_bool_t,
             :path_start_x, :float,
             :path_start_y, :float,
             :current_x,    :float,
             :current_y,    :float,
             :reserved1,    :uint32,
             :reserved2,    :uint32,
             :reserved3,    :uint32,
             :reserved4,    :uint32,
             :reserved5,    :uint32,
             :reserved6,    :uint32,
             :reserved7,    :uint32
    end
  end
end

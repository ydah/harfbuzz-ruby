# frozen_string_literal: true

module HarfBuzz
  module C
    # hb_memory_mode_t
    MemoryMode = enum :hb_memory_mode_t, [
      :duplicate, 0,
      :readonly,
      :writable,
      :readonly_may_make_writable
    ]

    # hb_direction_t
    Direction = enum :hb_direction_t, [
      :invalid, 0,
      :ltr, 4,
      :rtl, 5,
      :ttb, 6,
      :btt, 7
    ]

    # hb_buffer_content_type_t
    BufferContentType = enum :hb_buffer_content_type_t, [
      :invalid, 0,
      :unicode,
      :glyphs
    ]

    # hb_buffer_cluster_level_t
    BufferClusterLevel = enum :hb_buffer_cluster_level_t, [
      :monotone_graphemes, 0,
      :monotone_characters, 1,
      :characters, 2
    ]

    # hb_buffer_serialize_format_t
    BufferSerializeFormat = enum :hb_buffer_serialize_format_t, [
      :text, 0x54455854,
      :json, 0x4A534F4E,
      :invalid, 0x00000000
    ]

    # hb_unicode_general_category_t
    UnicodeGeneralCategory = enum :hb_unicode_general_category_t, [
      :control, 0,           :format, 1,
      :unassigned, 2,        :private_use, 3,
      :surrogate, 4,         :lowercase_letter, 5,
      :modifier_letter, 6,   :other_letter, 7,
      :titlecase_letter, 8,  :uppercase_letter, 9,
      :spacing_mark, 10,     :enclosing_mark, 11,
      :non_spacing_mark, 12, :decimal_number, 13,
      :letter_number, 14,    :other_number, 15,
      :connect_punctuation, 16, :dash_punctuation, 17,
      :close_punctuation, 18,   :final_punctuation, 19,
      :initial_punctuation, 20, :other_punctuation, 21,
      :open_punctuation, 22,    :currency_symbol, 23,
      :modifier_symbol, 24,     :math_symbol, 25,
      :other_symbol, 26,        :line_separator, 27,
      :paragraph_separator, 28, :space_separator, 29
    ]

    # hb_ot_layout_glyph_class_t
    OtLayoutGlyphClass = enum :hb_ot_layout_glyph_class_t, [
      :unclassified, 0, :base_glyph, 1,
      :ligature, 2, :mark, 3, :component, 4
    ]

    # hb_ot_meta_tag_t
    OtMetaTag = enum :hb_ot_meta_tag_t, [
      :design_languages, 0x646C6E67,
      :supported_languages, 0x736C6E67
    ]

    # hb_paint_composite_mode_t
    PaintCompositeMode = enum :hb_paint_composite_mode_t, [
      :clear, 0, :src, :dest, :src_over, :dest_over,
      :src_in, :dest_in, :src_out, :dest_out,
      :src_atop, :dest_atop, :xor, :plus,
      :screen, :overlay, :darken, :lighten,
      :color_dodge, :color_burn, :hard_light, :soft_light,
      :difference, :exclusion, :multiply,
      :hsl_hue, :hsl_saturation, :hsl_color, :hsl_luminosity
    ]

    # === Bit Flag Constants ===

    # hb_buffer_flags_t
    BUFFER_FLAG_DEFAULT                           = 0x00000000
    BUFFER_FLAG_BOT                               = 0x00000001
    BUFFER_FLAG_EOT                               = 0x00000002
    BUFFER_FLAG_PRESERVE_DEFAULT_IGNORABLES       = 0x00000004
    BUFFER_FLAG_REMOVE_DEFAULT_IGNORABLES         = 0x00000008
    BUFFER_FLAG_DO_NOT_INSERT_DOTTED_CIRCLE       = 0x00000010
    BUFFER_FLAG_VERIFY                            = 0x00000020
    BUFFER_FLAG_PRODUCE_UNSAFE_TO_CONCAT          = 0x00000040
    BUFFER_FLAG_PRODUCE_SAFE_TO_INSERT_TATWEEL    = 0x00000080
    BUFFER_FLAG_DEFINED                           = 0x000000FF

    # hb_buffer_serialize_flags_t
    BUFFER_SERIALIZE_FLAG_DEFAULT                 = 0x00000000
    BUFFER_SERIALIZE_FLAG_NO_CLUSTERS             = 0x00000001
    BUFFER_SERIALIZE_FLAG_NO_POSITIONS            = 0x00000002
    BUFFER_SERIALIZE_FLAG_NO_GLYPH_NAMES          = 0x00000004
    BUFFER_SERIALIZE_FLAG_GLYPH_EXTENTS           = 0x00000008
    BUFFER_SERIALIZE_FLAG_GLYPH_FLAGS             = 0x00000010
    BUFFER_SERIALIZE_FLAG_NO_ADVANCES             = 0x00000020

    # hb_buffer_diff_flags_t
    BUFFER_DIFF_FLAG_EQUAL                        = 0x0000
    BUFFER_DIFF_FLAG_CONTENT_TYPE_MISMATCH        = 0x0001
    BUFFER_DIFF_FLAG_LENGTH_MISMATCH              = 0x0002
    BUFFER_DIFF_FLAG_NOTDEF_PRESENT               = 0x0004
    BUFFER_DIFF_FLAG_DOTTED_CIRCLE_PRESENT        = 0x0008
    BUFFER_DIFF_FLAG_CODEPOINT_MISMATCH           = 0x0010
    BUFFER_DIFF_FLAG_CLUSTER_MISMATCH            = 0x0020
    BUFFER_DIFF_FLAG_GLYPH_FLAGS_MISMATCH         = 0x0040
    BUFFER_DIFF_FLAG_POSITION_MISMATCH            = 0x0080

    # hb_glyph_flags_t
    GLYPH_FLAG_UNSAFE_TO_BREAK                    = 0x00000001
    GLYPH_FLAG_UNSAFE_TO_CONCAT                   = 0x00000002
    GLYPH_FLAG_SAFE_TO_INSERT_TATWEEL             = 0x00000004
    GLYPH_FLAG_DEFINED                            = 0x00000007

    # hb_ot_var_axis_flags_t
    OT_VAR_AXIS_FLAG_HIDDEN                       = 0x0001

    # hb_ot_color_palette_flags_t
    OT_COLOR_PALETTE_FLAG_DEFAULT                 = 0x0000
    OT_COLOR_PALETTE_FLAG_USABLE_WITH_LIGHT_BG    = 0x0001
    OT_COLOR_PALETTE_FLAG_USABLE_WITH_DARK_BG     = 0x0002

    # hb_subset_flags_t
    SUBSET_FLAGS_DEFAULT                          = 0x0000
    SUBSET_FLAGS_NO_HINTING                       = 0x0001
    SUBSET_FLAGS_RETAIN_GIDS                      = 0x0002
    SUBSET_FLAGS_DESUBROUTINIZE                   = 0x0004
    SUBSET_FLAGS_NAME_LEGACY                      = 0x0008
    SUBSET_FLAGS_SET_OVERLAPS_FLAG                = 0x0010
    SUBSET_FLAGS_PASSTHROUGH_UNRECOGNIZED         = 0x0020
    SUBSET_FLAGS_NOTDEF_OUTLINE                   = 0x0040
    SUBSET_FLAGS_GLYPH_NAMES                      = 0x0080
    SUBSET_FLAGS_NO_PRUNE_UNICODE_RANGES          = 0x0100
    SUBSET_FLAGS_OPTIMIZE_IUP_DELTAS              = 0x0200
  end
end

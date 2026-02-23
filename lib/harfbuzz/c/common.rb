# frozen_string_literal: true

module HarfBuzz
  module C
    # hb_tag_t utilities
    attach_function :hb_tag_from_string, [:string, :int], :hb_tag_t
    attach_function :hb_tag_to_string, [:hb_tag_t, :pointer], :void

    # hb_direction_t utilities
    attach_function :hb_direction_from_string, [:string, :int], :hb_direction_t
    attach_function :hb_direction_to_string, [:hb_direction_t], :string

    # hb_language_t utilities
    attach_function :hb_language_from_string, [:string, :int], :pointer
    attach_function :hb_language_to_string, [:pointer], :string
    attach_function :hb_language_get_default, [], :pointer
    attach_function :hb_language_matches, [:pointer, :pointer], :hb_bool_t

    # hb_script_t utilities
    attach_function :hb_script_from_iso15924_tag, [:hb_tag_t], :uint32
    attach_function :hb_script_from_string, [:string, :int], :uint32
    attach_function :hb_script_to_iso15924_tag, [:uint32], :hb_tag_t
    attach_function :hb_script_get_horizontal_direction, [:uint32], :hb_direction_t

    # hb_feature_t utilities
    attach_function :hb_feature_from_string, [:string, :int, :pointer], :hb_bool_t
    attach_function :hb_feature_to_string, [:pointer, :pointer, :uint], :void

    # hb_variation_t utilities
    attach_function :hb_variation_from_string, [:string, :int, :pointer], :hb_bool_t
    attach_function :hb_variation_to_string, [:pointer, :pointer, :uint], :void

    # hb_color_t utilities
    attach_function :hb_color_get_alpha, [:hb_color_t], :uint8
    attach_function :hb_color_get_red, [:hb_color_t], :uint8
    attach_function :hb_color_get_green, [:hb_color_t], :uint8
    attach_function :hb_color_get_blue, [:hb_color_t], :uint8
  end
end

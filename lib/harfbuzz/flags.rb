# frozen_string_literal: true

module HarfBuzz
  # Utility module for converting between symbol arrays and bitwise flag integers
  #
  # @example Buffer flags
  #   flags = HarfBuzz::Flags.to_int(:buffer_flags, [:bot, :eot])
  #   buffer.flags = flags
  #
  # @example Subset flags
  #   flags = HarfBuzz::Flags.to_int(:subset_flags, [:no_hinting, :retain_gids])
  #   input.flags = flags
  module Flags
    # Maps flag set names to their symbol→integer mappings
    MAPPINGS = {
      buffer_flags: {
        default:                           C::BUFFER_FLAG_DEFAULT,
        bot:                               C::BUFFER_FLAG_BOT,
        eot:                               C::BUFFER_FLAG_EOT,
        preserve_default_ignorables:       C::BUFFER_FLAG_PRESERVE_DEFAULT_IGNORABLES,
        remove_default_ignorables:         C::BUFFER_FLAG_REMOVE_DEFAULT_IGNORABLES,
        do_not_insert_dotted_circle:       C::BUFFER_FLAG_DO_NOT_INSERT_DOTTED_CIRCLE,
        verify:                            C::BUFFER_FLAG_VERIFY,
        produce_unsafe_to_concat:          C::BUFFER_FLAG_PRODUCE_UNSAFE_TO_CONCAT,
        produce_safe_to_insert_tatweel:    C::BUFFER_FLAG_PRODUCE_SAFE_TO_INSERT_TATWEEL
      }.freeze,
      glyph_flags: {
        unsafe_to_break:                   C::GLYPH_FLAG_UNSAFE_TO_BREAK,
        unsafe_to_concat:                  C::GLYPH_FLAG_UNSAFE_TO_CONCAT,
        safe_to_insert_tatweel:            C::GLYPH_FLAG_SAFE_TO_INSERT_TATWEEL,
        defined:                           C::GLYPH_FLAG_DEFINED
      }.freeze,
      ot_var_axis_flags: {
        hidden:                            C::OT_VAR_AXIS_FLAG_HIDDEN
      }.freeze,
      subset_flags: {
        default:                           C::SUBSET_FLAGS_DEFAULT,
        no_hinting:                        C::SUBSET_FLAGS_NO_HINTING,
        retain_gids:                       C::SUBSET_FLAGS_RETAIN_GIDS,
        desubroutinize:                    C::SUBSET_FLAGS_DESUBROUTINIZE,
        name_legacy:                       C::SUBSET_FLAGS_NAME_LEGACY,
        set_overlaps_flag:                 C::SUBSET_FLAGS_SET_OVERLAPS_FLAG,
        passthrough_unrecognized:          C::SUBSET_FLAGS_PASSTHROUGH_UNRECOGNIZED,
        notdef_outline:                    C::SUBSET_FLAGS_NOTDEF_OUTLINE,
        glyph_names:                       C::SUBSET_FLAGS_GLYPH_NAMES,
        no_prune_unicode_ranges:           C::SUBSET_FLAGS_NO_PRUNE_UNICODE_RANGES,
        optimize_iup_deltas:               C::SUBSET_FLAGS_OPTIMIZE_IUP_DELTAS
      }.freeze
    }.freeze

    # Converts an array of symbols to a bitwise flag integer
    # @param mapping_name [Symbol] Name of the flag mapping (e.g., :buffer_flags)
    # @param symbols [Array<Symbol>] Flag symbols to combine
    # @return [Integer] Combined bitmask
    # @raise [ArgumentError] If mapping_name or a symbol is unknown
    def self.to_int(mapping_name, symbols)
      mapping = MAPPINGS.fetch(mapping_name) do
        raise ArgumentError, "Unknown flag mapping: #{mapping_name.inspect}. " \
                             "Available: #{MAPPINGS.keys.inspect}"
      end

      Array(symbols).inject(0) do |acc, sym|
        bit = mapping.fetch(sym) do
          raise ArgumentError, "Unknown flag #{sym.inspect} in #{mapping_name}. " \
                               "Available: #{mapping.keys.inspect}"
        end
        acc | bit
      end
    end

    # Converts a bitwise flag integer to an array of symbols
    # @param mapping_name [Symbol] Name of the flag mapping
    # @param int_value [Integer] Bitmask to decode
    # @return [Array<Symbol>] Symbols whose bits are set
    # @raise [ArgumentError] If mapping_name is unknown
    def self.to_symbols(mapping_name, int_value)
      mapping = MAPPINGS.fetch(mapping_name) do
        raise ArgumentError, "Unknown flag mapping: #{mapping_name.inspect}. " \
                             "Available: #{MAPPINGS.keys.inspect}"
      end

      mapping.filter_map { |sym, bit| sym if bit != 0 && (int_value & bit) == bit }
    end
  end
end

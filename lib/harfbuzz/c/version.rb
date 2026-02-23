# frozen_string_literal: true

module HarfBuzz
  module C
    # === Version Functions ===

    # Returns the HarfBuzz library version
    # @param major [FFI::Pointer] Pointer to store major version
    # @param minor [FFI::Pointer] Pointer to store minor version
    # @param micro [FFI::Pointer] Pointer to store micro version
    # @return [void]
    attach_function :hb_version, [:pointer, :pointer, :pointer], :void

    # Returns the HarfBuzz library version as a string
    # @return [String] Version string (e.g., "8.3.0")
    attach_function :hb_version_string, [], :string

    # Checks if the library version is at least the specified version
    # @param major [Integer] Major version
    # @param minor [Integer] Minor version
    # @param micro [Integer] Micro version
    # @return [Integer] Non-zero if version >= specified, 0 otherwise
    attach_function :hb_version_atleast, [:uint, :uint, :uint], :hb_bool_t
  end
end

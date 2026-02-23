# frozen_string_literal: true

module HarfBuzz
  # Base error class for all HarfBuzz errors
  class Error < StandardError; end

  # Raised when the HarfBuzz shared library cannot be found
  class LibraryNotFoundError < Error; end

  # Raised when memory allocation fails (create functions return NULL)
  class AllocationError < Error; end

  # Raised when an invalid argument is passed to a function
  class InvalidArgumentError < Error; end

  # Raised when a Feature string cannot be parsed
  class FeatureParseError < Error; end

  # Raised when a Variation string cannot be parsed
  class VariationParseError < Error; end

  # Raised when hb_subset_or_fail or similar operations fail
  class SubsetError < Error; end

  # Raised when an optional feature (FreeType, Subset) is unavailable
  class UnavailableError < Error; end
end

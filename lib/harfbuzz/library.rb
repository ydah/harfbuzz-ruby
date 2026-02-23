# frozen_string_literal: true

require "rbconfig"

module HarfBuzz
  # Returns the path to the HarfBuzz shared library
  # @return [String, Array<String>] Library path or array of library names for FFI to search
  def self.library_path
    @library_path ||= detect_library
  end

  # Sets the library path explicitly
  # @param path [String] Path to the HarfBuzz shared library
  def self.library_path=(path)
    @library_path = path
  end

  # Detects the HarfBuzz shared library location
  # @return [String, Array<String>] Library path or array of library names
  # @raise [LibraryNotFoundError] If library cannot be found
  private_class_method def self.detect_library
    # 1. Environment variable override
    if (env_path = ENV.fetch("HARFBUZZ_LIB_PATH", nil))
      return env_path if File.exist?(env_path)

      warn "HARFBUZZ_LIB_PATH=#{env_path} does not exist, falling back to auto-detection"
    end

    # 2. pkg-config (most reliable)
    pkg_config_path = try_pkg_config
    return pkg_config_path if pkg_config_path

    # 3. Platform-specific default paths
    platform_path = try_platform_paths
    return platform_path if platform_path

    # 4. Let FFI search via ldconfig / dyld (return array of library names)
    ["harfbuzz", "libharfbuzz", "libharfbuzz-0"]
  end

  # Tries to find library path using pkg-config
  # @return [String, nil] Library path if found
  private_class_method def self.try_pkg_config
    # Suppress mkmf output
    libs = `pkg-config --libs harfbuzz 2>/dev/null`.strip
    return nil if libs.empty?

    lib_dir = libs[/-L(\S+)/, 1]
    return nil unless lib_dir

    ext = lib_extension
    path = File.join(lib_dir, "libharfbuzz.#{ext}")
    File.exist?(path) ? path : nil
  rescue StandardError
    nil
  end

  # Tries platform-specific library paths
  # @return [String, nil] Library path if found
  private_class_method def self.try_platform_paths
    candidates = case RbConfig::CONFIG["host_os"]
                 when /darwin/i
                   %w[
                     /opt/homebrew/lib/libharfbuzz.dylib
                     /usr/local/lib/libharfbuzz.dylib
                     /opt/local/lib/libharfbuzz.dylib
                   ]
                 when /linux/i
                   %w[
                     /usr/lib/x86_64-linux-gnu/libharfbuzz.so
                     /usr/lib/aarch64-linux-gnu/libharfbuzz.so
                     /usr/lib64/libharfbuzz.so
                     /usr/lib/libharfbuzz.so
                     /usr/local/lib/libharfbuzz.so
                   ]
                 when /mingw|mswin|cygwin/i
                   %w[
                     C:/msys64/mingw64/bin/libharfbuzz-0.dll
                     C:/msys64/ucrt64/bin/libharfbuzz-0.dll
                     C:/msys64/clang64/bin/libharfbuzz-0.dll
                   ]
                 else
                   []
                 end

    candidates.find { |p| File.exist?(p) }
  end

  # Returns the library extension for the current platform
  # @return [String] Library extension (.dylib, .so, or .dll)
  private_class_method def self.lib_extension
    case RbConfig::CONFIG["host_os"]
    when /darwin/i then "dylib"
    when /mingw|mswin|cygwin/i then "dll"
    else "so"
    end
  end
end

# frozen_string_literal: true

# SimpleCov must be loaded before the application code
if ENV.fetch("COVERAGE", nil) == "true"
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/vendor/"
    enable_coverage :branch
    minimum_coverage line: 90, branch: 80
  end
end

require "harfbuzz"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Tag :integration for tests that require real font files
  # Tag :memory for memory leak tests
  config.filter_run_excluding :memory unless ENV["RUN_MEMORY_TESTS"]

  # Helper: fixture font path
  config.include(Module.new do
    def fixture_font_path(name = "Helvetica.ttc")
      File.expand_path("../fixtures/fonts/#{name}", __dir__)
    end

    def system_font_path
      if File.exist?("/System/Library/Fonts/Helvetica.ttc")
        "/System/Library/Fonts/Helvetica.ttc"
      elsif File.exist?("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
      else
        raise "No test font found"
      end
    end
  end)
end

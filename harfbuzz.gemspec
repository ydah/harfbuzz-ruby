# frozen_string_literal: true

require_relative "lib/harfbuzz/version"

Gem::Specification.new do |spec|
  spec.name = "harfbuzz-ruby"
  spec.version = HarfBuzz::VERSION
  spec.authors = ["Yudai Takada"]
  spec.email = ["t.yudai92@gmail.com"]
  spec.summary = "Complete Ruby FFI bindings for HarfBuzz text shaping engine"
  spec.description = "Complete Ruby bindings for HarfBuzz using FFI. Covers Core API, OpenType Layout, Variable Fonts, AAT, Subset API, and more."
  spec.homepage = "https://github.com/ydah/harfbuzz"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ydah/harfbuzz"
  spec.metadata["changelog_uri"] = "https://github.com/ydah/harfbuzz/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "ffi", "~> 1.15"
end

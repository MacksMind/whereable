# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require_relative 'lib/whereable/version'

Gem::Specification.new do |spec|
  spec.name          = 'whereable'
  spec.version       = Whereable::VERSION
  spec.authors       = ['Mack Earnhardt']
  spec.email         = ['mack@agilereasoning.com']

  spec.summary       = 'Translates where-like filter syntax into an Arel-based ActiveRecord scope.'
  spec.description   = <<~DESC
    Translates where-like filter syntax into an Arel-based ActiveRecord scope,
    so you can safely use SQL syntax in Rails controller parameters.
    Not as powerful as Ransack, but simple and lightweight.
  DESC
  spec.homepage      = 'https://github.com/MacksMind/whereable'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `find lib -name '*.rb' -print0`.split("\x0") +
        `find . -name '*.treetop' -print0`.split("\x0") +
        `find . -name '*.txt' -print0`.split("\x0") +
        `find . -name '*.md' -print0`.split("\x0")
    end
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'treetop'
end

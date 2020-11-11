# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require 'bundler/setup'
require 'database_cleaner'
require 'whereable'
require 'pry'

begin
  ENV['RAILS_ENV'] ||= 'test'
  database_config = YAML.load_file(File.join(__dir__, '../config/database.yml'))
  ActiveRecord::Base.establish_connection(database_config[ENV['RAILS_ENV']])
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Pull in the dummy model(s)
Dir[File.join(__dir__, 'dummy/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  # Clean up the database
  require 'database_cleaner/active_record'

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end

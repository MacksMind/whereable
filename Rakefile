# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'active_record'
load 'active_record/railties/databases.rake'

namespace :db do
  task :environment do
    include ActiveRecord::Tasks
    ENV['RAILS_ENV'] ||= 'development'
    DatabaseTasks.env = ENV['RAILS_ENV']
    DatabaseTasks.root = __dir__
    DatabaseTasks.db_dir = File.join(__dir__, 'db')
    DatabaseTasks.migrations_paths = File.join(DatabaseTasks.db_dir, 'migrate')
    database_config = YAML.load_file(File.join(__dir__, 'config/database.yml'))
    DatabaseTasks.database_configuration = database_config
    ActiveRecord::Base.establish_connection(database_config[ENV['RAILS_ENV']])
    require_relative File.join(DatabaseTasks.db_dir, 'seeds')
    DatabaseTasks.seed_loader = Seeds
  end
end

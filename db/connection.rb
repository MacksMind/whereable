# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

ENV['RAILS_ENV'] ||= 'development'

database_config = YAML.load_file(File.join(__dir__, '../config/database.yml'))
ActiveRecord::Base.establish_connection(database_config[ENV['RAILS_ENV']])

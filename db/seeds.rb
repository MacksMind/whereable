# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

Dir[File.join(__dir__, '../spec/dummy/**/*.rb')].sort.each { |f| require f }

# Seed loader class
class Seeds
  class << self
    # Load the database seeds
    def load_seed
      User.create!(username: 'Morpheus', role: :admin, born_on: '1961-07-30')
      User.create!(username: 'Neo', role: :standard, born_on: '1964-09-02')
    end
  end
end

# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

Dir[File.join(__dir__, '../spec/dummy/**/*.rb')].sort.each { |f| require f }

# Seed loader module
module Seeds
  class << self
    # Load the database seeds
    def load_seed
      morpheus = User.create!(username: 'Morpheus', role: :admin, born_on: '1961-07-30')
      neo = User.create!(username: 'Neo', role: :standard, born_on: '1964-09-02')
      Visit.create!(user: morpheus, city: 'Denver', visit_on: 5.days.ago, score: 35)
      Visit.create!(user: neo, city: 'Albuquerque', visit_on: 3.days.ago, score: 73)
    end
  end
end

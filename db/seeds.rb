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
      trinity = User.create!(username: 'Trinity', role: :standard, born_on: '1964-09-02')
      Post.create!(user: morpheus, title: 'Denver', publish_at: 5.days.ago, words: 35)
      Post.create!(user: neo, title: 'Albuquerque', publish_at: 3.days.ago, words: 73)
      Post.create!(user: trinity, title: 'San Francisco', publish_at: 1.days.ago, words: 93)
    end
  end
end

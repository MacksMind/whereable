# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true

  enum role: { standard: 0, admin: 1 }

  has_many :visits
end

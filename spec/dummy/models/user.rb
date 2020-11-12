# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class User < ActiveRecord::Base
  include Whereable

  validates :username, presence: true, uniqueness: true

  enum role: { standard: 0, admin: 1 }
end

# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class Visit < ApplicationRecord
  belongs_to :user

  validates :city, presence: true
  validates :visit_on, presence: true
end

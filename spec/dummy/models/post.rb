# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
end

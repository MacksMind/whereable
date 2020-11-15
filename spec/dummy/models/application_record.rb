# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class ApplicationRecord < ActiveRecord::Base
  include Whereable

  self.abstract_class = true
end

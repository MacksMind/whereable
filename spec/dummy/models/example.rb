# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class Example < ActiveRecord::Base
  include Whereable

  enum role: { standard: 0, admin: 1 }
end

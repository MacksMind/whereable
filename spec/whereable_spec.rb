# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

RSpec.describe Whereable do
  it 'has a version number' do
    expect(Whereable::VERSION).not_to be(nil)
  end
end

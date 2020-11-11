# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

# Migration
class CreateExamples < ActiveRecord::Migration[6.0]
  # Create examples table
  def change
    create_table :examples do |t|
      t.text    :username
      t.integer :role, null: false, default: 0
      t.date    :born_on

      t.timestamps
    end
  end
end

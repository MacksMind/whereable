# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class CreateUsers < ActiveRecord::Migration[6.0]
  # Create users table
  def change
    create_table :users do |t|
      t.text    :username
      t.integer :role, null: false, default: 0
      t.date    :born_on

      t.timestamps
    end
  end
end

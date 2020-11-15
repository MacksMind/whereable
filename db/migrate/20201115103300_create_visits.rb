# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class CreateVisits < ActiveRecord::Migration[6.0]
  # Create visits table
  def change
    create_table :visits do |t|
      t.references  :user, null: false
      t.text        :city, null: false
      t.date        :visit_on, null: false
      t.integer     :score

      t.timestamps
    end

    add_foreign_key :visits, :users
  end
end

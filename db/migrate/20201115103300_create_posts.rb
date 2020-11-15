# frozen_string_literal: true

# Copyright 2020 Mack Earnhardt

class CreatePosts < ActiveRecord::Migration[6.0]
  # Create posts table
  def change
    create_table :posts do |t|
      t.references  :user, null: false
      t.text        :title, null: false
      t.date        :publish_at
      t.integer     :words

      t.timestamps
    end

    add_foreign_key :posts, :users
  end
end

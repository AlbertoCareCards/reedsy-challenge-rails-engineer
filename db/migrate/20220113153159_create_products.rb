# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false, unique: true
      t.string :code, null: false, unique: true
      t.monetize :price, null: false

      t.timestamps
    end
  end
end

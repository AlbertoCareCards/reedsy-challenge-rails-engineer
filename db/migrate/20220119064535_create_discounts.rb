# frozen_string_literal: true

class CreateDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :discounts do |t|
      t.integer :min_amount, null: true
      t.integer :max_amount, null: true
      t.string :description
      t.float :reduction, null: false

      t.timestamps
    end
  end
end

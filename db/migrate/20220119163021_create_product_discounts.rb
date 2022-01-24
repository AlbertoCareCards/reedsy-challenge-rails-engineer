# frozen_string_literal: true

class CreateProductDiscounts < ActiveRecord::Migration[7.0]
  def change
    create_table :product_discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :discount, null: false, foreign_key: true

      t.timestamps
    end
  end
end

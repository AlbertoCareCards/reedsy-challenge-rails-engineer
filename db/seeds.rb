# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Seed Products
# -------------
products = [
  {
    id: 1,
    price: 6,
    code: 'mug',
    name: 'Reedsy Mug',
  },
  {
    id: 2,
    price: 15,
    code: 'tshirt',
    name: 'Reedsy T-shirt',
  },
  {
    id: 3,
    price: 20,
    code: 'hoodie',
    name: 'Reedsy Hoodie',
  },
]

Product.create(products)

# Discounts
# ---------
discounts = [
  {
    id: 1,
    min_amount: 2,
    max_amount: 2,
    reduction: 0.5,
    description: '2x1 in mugs!',
    product_ids: [1],
  },
  {
    id: 2,
    min_amount: 3,
    reduction: 0.3,
    description: '30% discount in t-shirts when buying 3 or more!',
    product_ids: [2],
  },
]

Discount.create(discounts)

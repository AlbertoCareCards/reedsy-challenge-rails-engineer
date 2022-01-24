# frozen_string_literal: true

Rails.application.routes.draw do
  apipie
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      # Product Routes
      # Restricted product API interface according to Challenge Question 1
      resources :products, only: [:index, :update]

      # Basket Routes
      get '/basket/check', to: 'basket#check'
    end
  end
end

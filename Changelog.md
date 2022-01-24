# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2022-01-22
### Added
- API Endpoint for listing products updated
  - Endpoint accepts filter parameters for name and code attributes
  - Endpoint accepts sort parameters

## [1.0.0] - 2022-01-22
### Added
- API Endpoint for listing products
  - Products can be listed in multiple currencies
  - Products list can be paginated
- API Endpoint for updating product prices
  - Product prices can be updated in multiple currencies
- API Endpoint for basket information
  - Products can be specified to define baskets
  - Basket provides the total price of its items
  - Basket provides optimal price of its items with all applicable discounts
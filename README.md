# Cornerstore

This is a client for the Cornerstore e-commerce API

## Installation

Add this line to your application's Gemfile:

    gem 'cornerstore'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cornerstore
    
## Usage

    product = Cornerstore::Product.find("5107c57596c70bbb82000013")
    first_variant = product.variants.first
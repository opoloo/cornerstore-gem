require 'active_model'
require 'rest_client'

require 'cornerstore/version'
require 'cornerstore/base'
require 'cornerstore/resource'
require 'cornerstore/product'
require 'cornerstore/variant'
require 'cornerstore/price'
require 'cornerstore/collection'
require 'cornerstore/cart'
require 'cornerstore/line_item'

require_relative '../tests/dummy'

module Cornerstore
  def self.options
    @options ||= {
      account_name: 'burger-store'
    }
  end
  def self.root_url
    "http://#{Cornerstore.options[:account_name]}.cskit.monkeyandco.net/api"  
  end
end
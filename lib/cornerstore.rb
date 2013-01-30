require 'active_model'
require 'rest_client'

require 'cornerstore/version'
require 'cornerstore/base'
require 'cornerstore/product'
require 'cornerstore/variant'
require 'cornerstore/price'

module Cornerstore
  def self.options
    @options ||= {
      :account_name => 'burger-store'
    }
  end
end
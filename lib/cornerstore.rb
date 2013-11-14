require 'active_model'
require 'rest_client'

require 'cornerstore/version'
require 'cornerstore/resource'
require 'cornerstore/model'
require 'cornerstore/api'

require_relative '../tests/dummy'

module RestClient::AbstractResponse
  def success?
    (200..207).include? code
  end
end

RestClient.log = 'stdout'

module Cornerstore
  def self.options
    @options ||= {
      account_name: 'burger-store'
    }
  end
  def self.root_url
    "https://api.#{Cornerstore.options[:account_name]}.cornerstore.io/v1"
  end

  def self.assets_url
    "http://cskit-production.s3.amazonaws.com"
  end
end

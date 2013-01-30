class Cornerstore::Product < Cornerstore::Base
  attr_accessor :name,
                :description,
                :manufacturer, 
                :variants
  
  def initialize(attributes = {})
    super
    self.variants = attributes['variants'].map{|variant_hash| Cornerstore::Variant.new(variant_hash)} if attributes['variants']
    self
  end
  
  def self.all
    response = RestClient.get("http://#{Cornerstore.options[:account_name]}.cskit.monkeyandco.net/api/products.json")
    array = ActiveSupport::JSON.decode(response)
    array.map{|product_hash| self.new(product_hash)}
  end
  
  def self.find(id)
    response = RestClient.get("http://#{Cornerstore.options[:account_name]}.cskit.monkeyandco.net/api/products/#{id}.json")
    hash = ActiveSupport::JSON.decode(response)
    self.new(hash)
  end
end
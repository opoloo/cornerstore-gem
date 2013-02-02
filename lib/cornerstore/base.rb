class Cornerstore::Base
  include ActiveModel::Validations
  include ActiveModel::Serializers::JSON
  self.include_root_in_json = false
  
  attr_accessor :_id
  def id
    _id
  end
  
  def initialize(attributes = {})  
    self.attributes = attributes
  end
  
  def attributes=(attributes = {})
    attributes.each do |name, value|  
      send("#{name}=", value) if respond_to?("#{name}=")
    end 
  end
  
  def self.method_missing(method, *args, &block)
    if self.const_defined?("Resource") and self.const_get("Resource").method_defined?(method)
      self.const_get("Resource").new.send(method, *args, &block)
    else
      super
    end
  end  
end
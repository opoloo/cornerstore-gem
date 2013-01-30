class Cornerstore::Base
  include ActiveModel::Validations
  include ActiveModel::Serializers::JSON
  self.include_root_in_json = false
  
  attr_accessor :_id
  
  def initialize(attributes = {})  
    self.attributes = attributes
  end
  
  def attributes=(attributes = {})
    attributes.each do |name, value|  
      send("#{name}=", value) if respond_to?("#{name}=")
    end 
  end
  
  def to_param
    self._id
  end
end
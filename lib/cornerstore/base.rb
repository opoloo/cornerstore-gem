class Cornerstore::Base
  include ActiveModel::Validations
  
  attr_accessor :_id
  def id
    _id
  end
  
  def initialize(attributes = {})  
    self.attributes = attributes
    yield self if block_given?
  end
  
  def attributes=(attributes)
    attributes ||= {}
    attributes.each do |name, value|  
      send("#{name}=", value) if respond_to?("#{name}=")
    end 
  end
  
  def new?
    id.nil?
  end
  alias new_record? new?
  
  def self.create(attributes = {}, &block)
    self.new(attributes, &block).tap{|obj| obj.save}
  end
  
  def self.method_missing(method, *args, &block)
    if self.const_defined?("Resource") and self.const_get("Resource").method_defined?(method)
      self.const_get("Resource").new.send(method, *args, &block)
    else
      super
    end
  end  
end
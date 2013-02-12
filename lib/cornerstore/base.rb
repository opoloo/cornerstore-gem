class Cornerstore::Base  
  attr_accessor :_id
  attr_accessor :parent
  
  def id
    _id
  end
  
  def initialize(attributes = {}, parent = nil)  
    self.attributes = attributes
    self.parent = parent
  end
  
  def attributes
    {}
  end
  
  def attributes=(attributes)
    attributes ||= {}
    attributes.each do |name, value|  
      send("#{name}=", value) if respond_to?("#{name}=")
    end 
  end
  
  def new?
    false
  end
  
  def url
    if @parent
      "#{@parent.url}/#{self.class.name.split('::').last.underscore.pluralize}/#{id}"
    else
      "#{Cornerstore.root_url}/#{self.class.name.split('::').last.underscore.pluralize}/#{id}"
    end
  end
  
  def save
    raise "Sorry, this part of the Cornerstore-API is currently read-only"
  end
  
  def destroy
    raise "Sorry, this part of the Cornerstore-API is currently read-only"
  end
  
  def create
    raise "Sorry, this part of the Cornerstore-API is currently read-only"
  end
  
  def self.method_missing(method, *args, &block)
    if self.const_defined?("Resource") and self.const_get("Resource").method_defined?(method)
      self.const_get("Resource").new.send(method, *args, &block)
    else
      super
    end
  end  
end

class Cornerstore::Writable < Cornerstore::Base
  include ActiveModel::Validations
  
  def initialize(attributes={}, parent=nil)
    super
    yield self if block_given?
  end
  
  def new?
    id.nil?
  end
  alias new_record? new?
  
  def url
    if @parent
      "#{@parent.url}/#{self.class.name.split('::').last.underscore.pluralize}/#{id unless new?}"
    else
      "#{Cornerstore.root_url}/#{self.class.name.split('::').last.underscore.pluralize}/#{id unless new?}"
    end
  end

  def save
    return false unless valid?
    wrapped_attributes = Hash.new.store(self.class.name.split('::').last.downcase, self.attributes)
    if new_record?
      response = RestClient.post(url, wrapped_attributes){|response| response}
      self.attributes = ActiveSupport::JSON.decode(response)
    else
      response = RestClient.patch(url, wrapped_attributes){|response| response}
    end
    response.success?
  end
  
  def destroy
    response = RestClient.delete(to_url)
    response.success?
  end

  def self.create(attributes = {}, &block)
    self.new(attributes, &block).tap{|obj| obj.save}
  end
end
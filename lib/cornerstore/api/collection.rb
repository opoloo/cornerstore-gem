class Cornerstore::Collection < Cornerstore::Model::Base
  attr_accessor :name,
                :parent,
                :members,
                :childs,
                :products,
                :properties
                
  def initialize(attributes = {}, parent = nil)
    self.products = Cornerstore::Product::Resource.new(self)
    self.childs = Cornerstore::Collection::Resource.new(self, attributes.delete('child_collections') || [], 'childs')
    self.properties = Cornerstore::Property::Resource.new(self, attributes.delete('properties') || [])
    super
  end
  
  def attributes
    {
      name: name
    }
  end
  
  class Resource < Cornerstore::Resource::Base
    include Cornerstore::Resource::Remote
  end
end
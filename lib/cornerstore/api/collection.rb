class Cornerstore::Collection < Cornerstore::Model::Base
  attr_accessor :name,
                :parent,
                :members,
                :childs,
                :products
                
  def initialize(attributes = {}, parent = nil)
    self.products = Cornerstore::Product::Resource.new(self)
    self.childs = Cornerstore::Collection::Resource.new(self, attributes.delete('child_collections') || [], 'childs')
    super
  end

  def to_param
    "#{_id}-#{name.parameterize}"
  end
  
  class Resource < Cornerstore::Resource::Base
    include Cornerstore::Resource::Remote
  end
end
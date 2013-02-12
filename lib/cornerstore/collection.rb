class Cornerstore::Collection < Cornerstore::Base
  attr_accessor :name,
                :parent,
                :members,
                :childs,
                :products
                
  def initialize(attributes = {}, parent=nil)
    self.products = Cornerstore::Product::Resource.new(self)
    self.childs = Cornerstore::Collection::Resource.new(self)
    if childs_attributes = attributes.delete('child_collections')
      self.childs.concat childs_attributes.map {|hash| Cornerstore::Collection.new(hash, self)}
    end
    super
  end

  def to_param
    "#{_id}-#{name.parameterize}"
  end
  
  class Resource < Cornerstore::Resource
  end
end
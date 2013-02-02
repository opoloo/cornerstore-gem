class Cornerstore::Collection < Cornerstore::Base
  attr_accessor :name,
                :parent,
                :members,
                :childs,
                :products
                
  def initialize(attributes = {})
    # Sub-collections might be nested
    if collections_attributes = attributes.delete('collections')
      self.childs = collections_attributes.map do |collection_hash|
        collection = Cornerstore::Collection.new(collection_hash)
        collection.parent = self
        collection
      end
    end
    super
  end

  def to_param
    "#{_id}-#{name.parameterize}"
  end
  
  def products
    products ||= Cornerstore::Product.find_by_collection(_id)
  end
  
  class Resource < Cornerstore::Resource
  end
end
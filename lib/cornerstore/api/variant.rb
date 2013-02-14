class Cornerstore::Variant < Cornerstore::Model::Base
  attr_accessor :order_number,
                :price
                
  alias product parent
  
  def attributes
    {
      order_number: order_number,
      price: price
    }
  end
                
  def initialize(attributes = {}, parent = nil)
    self.price = Cornerstore::Price.new(attributes.delete('price'))
    super
  end
  
  class Resource < Cornerstore::Resource::Base
  end
end
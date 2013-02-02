class Cornerstore::Variant < Cornerstore::Base
  attr_accessor :order_number,
                :price,
                :product
                
  def initialize(attributes = {})
    self.price = Cornerstore::Price.new(attributes.delete('price'))
    super
  end
end
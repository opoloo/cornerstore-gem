class Cornerstore::Variant < Cornerstore::Base
  attr_accessor :order_number,
                :price
                
  def initialize(attributes = {})
    super
    self.price = Cornerstore::Price.new(attributes['price'])
  end
end
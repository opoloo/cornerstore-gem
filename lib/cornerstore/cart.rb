class Cornerstore::Cart < Cornerstore::Writable
  attr_accessor :line_items
  
  def initialize(attributes = {}, parent=nil)
    self.line_items = Cornerstore::LineItem::Resource.new(self)
    if line_items_attributes = attributes.delete('line_items')
      self.line_items.concat line_items_attributes.map {|hash| Cornerstore::LineItem.new(hash, self)}
    end
    super
  end
  
  def total
    line_items.inject(0) {|sum,item| sum + item.price.gross}
  end
  
  def empty
    line_items.delete_all
    line_items.empty?
  end
  
  def empty?
    line_items.empty?
  end

  class Resource < Cornerstore::WritableResource
    
    def find_or_create_by_session
      if not session[:cart_id] or not cart = find_by_id(session[:cart_id])
        cart = Cart.create
        session[:cart_id] = cart.id
      end
      cart
    end
    
  end
end
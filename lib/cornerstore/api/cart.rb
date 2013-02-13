class Cornerstore::Cart < Cornerstore::Model::Base
  include Cornerstore::Model::Writable
  
  attr_accessor :line_items
  
  def initialize(attributes = {}, parent=nil)
    self.line_items = Cornerstore::LineItem::Resource.new(self, attributes.delete('line_items') || [])
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

  class Resource < Cornerstore::Resource::Base
    include Cornerstore::Resource::Remote
    include Cornerstore::Resource::Writable
    
    def find_or_create_by_session
      if not session[:cart_id] or not cart = find_by_id(session[:cart_id])
        cart = Cart.create
        session[:cart_id] = cart.id
      end
      cart
    end
    
  end
end
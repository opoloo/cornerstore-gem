class Cornerstore::Cart < Cornerstore::Base
  attr_accessor :line_items
  
  def initialize(attributes = {})
    self.line_items = Cornerstore::LineItem::Resource.new(self)
    if line_items = attributes.delete('line_items')
      self.line_items.concat line_items.map do |hash|
        line_item = Cornerstore::LineItem.new(hash)
        line_item.cart = self
        line_item
      end
    end
    super
  end
  
  def total
    
  end
  
  def self.create
    self.new.save
  end
  
  def new_record?
    id.nil?
  end
  
  def save
    if new_record?
      response = RestClient.post("#{Cornerstore.root_url}/carts.json", {})  
      self.attributes = ActiveSupport::JSON.decode(response)
    end
    self
  end

  class Resource < Cornerstore::Resource
    
    def find_or_create_by_session
      if not session[:cart_id] or not cart = find_by_id(session[:cart_id])
        cart = Cart.create
        session[:cart_id] = cart.id
      end
      cart
    end
    
  end
end
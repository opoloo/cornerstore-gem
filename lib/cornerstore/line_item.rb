class Cornerstore::LineItem < Cornerstore::Base
  attr_accessor :order_number,
                :description,
                :qty,
                :unit,
                :price,
                :weight,
                :cart
                
  validates :order_number, length: { within: 1..50 }
  validates :description, length: { within: 1..255 }
  validates :qty, numericality: { greater_than: 0, only_integer: true }
  validates :unit, length: { within: 1..20 }
  validates :price, presence: true
  validates :weight, numericality: { greater_than: 0, allow_nil: true }
  validate do
    errors.add(:price, 'Price must be valid') unless price.valid?
  end
  
  def initialize(attributes={})
    self.price = Cornerstore::Price.new(attributes.delete('price'))
    super
  end
  
  def attributes
    {
      order_number: order_number,
      description: description,
      qty: qty,
      unit: unit,
      price: price.attributes,
      weight: weight
    }
  end
  
  def save
    return false unless valid?
    if new_record?
      response = RestClient.post("#{Cornerstore.root_url}/carts/#{cart.id}/line_items.json", line_item: self.attributes){|response| response}
      attributes = ActiveSupport::JSON.decode(response)
    else
      response = RestClient.patch("#{Cornerstore.root_url}/carts/#{cart.id}/line_items/#{id}.json", line_item: self.attributes){|response| response}
    end
    response.success?
  end
  
  def destroy
    response = RestClient.delete("#{Cornerstore.root_url}/carts/#{cart.id}/line_items/#{id}.json")
    response.success?
  end
  
  class Resource
    def initialize(parent)
      @klass = Cornerstore::LineItem
      @objects = Array.new
      @parent = parent
    end
    
    def <<(line_item)
      @objects << line_item
      line_item.cart = @parent
      self
    end
    alias_method :push, :<<
    
    def new(attributes={}, &block)
      line_item = @klass.new(attributes, &block)
      push line_item
      line_item
    end
    
    def create(attributes={}, &block)
      attributes['cart'] = @parent
      line_item = @klass.new(attributes, &block)
      if line_item.save
        push line_item
        line_item
      else
        nil
      end
    end
    
    def create_from_variant(variant)
      attributes = {
        variant_id: variant.id,
        product_id: variant.product.id
      }
      response = RestClient.post("#{Cornerstore.root_url}/carts/#{@parent.id}/line_items/derive.json", attributes)  
      attributes = ActiveSupport::JSON.decode(response)
      line_item = @klass.new(attributes)
      push line_item
      line_item
    end
    
    def destroy_all
      @objects.delete_if {|obj| obj.destroy}
      self
    end
    
    def to_a
      @objects
    end
    
    def method_missing(method, *args, &block)
      if Array.method_defined?(method)
        to_a.send(method, *args, &block)
      else
        super
      end
    end
  end
end
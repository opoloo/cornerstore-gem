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
  
  def new_record?
    id.nil?
  end
  
  def save
    attributes = {
      order_number: order_number,
      description: description,
      qty: qty,
      unit: unit,
      price: price,
      weight: weight
    }
    begin
      if new_record?
        response = RestClient.post("#{Cornerstore.root_url}/carts/#{cart.id}/line_items.json", line_item: attributes)  
        attributes = ActiveSupport::JSON.decode(response)
      else
        response = RestClient.patch("#{Cornerstore.root_url}/carts/#{cart.id}/line_items/#{id}.json", line_item: attributes)
      end
    rescue => e
      puts e.response
    end
    response.code == 200
  end
  
  def destroy
    
  end
  
  class Resource
    def initialize(parent)
      @klass = Cornerstore.const_get(self.class.name.split('::')[-2])
      @objects = Array.new
      @parent = parent
    end
    
    def <<(line_item)
      @objects << line_item
      line_item.cart = @parent
      self
    end
    alias_method :push, :<<
    
    def new(attributes={})
      line_item = @klass.new(attributes)
      push line_item
      line_item
    end
    
    def create(attributes={})
      attributes['cart'] = @parent
      line_item = @klass.new(attributes).save
      push line_item
      line_item
    end
    
    def create_from_variant(variant)
      attributes = {
        variant_id: variant.id,
        product_id: variant.product.id
      }
      begin
        response = RestClient.post("#{Cornerstore.root_url}/carts/#{@parent.id}/line_items/derive.json", attributes)  
      rescue => e
        puts e.response
      end
      attributes = ActiveSupport::JSON.decode(response)
      line_item = @klass.new(attributes)
      push line_item
      line_item
    end
    
    def destroy_all
      
    end
    alias empty destroy_all
    
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
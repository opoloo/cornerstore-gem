module Cornerstore::Tests
  def self.get_some_products
    all_collections = Cornerstore::Collection.all
    
    child_collection = Cornerstore::Collection.all.first.childs.first
    
    products_from_child_collection = child_collection.products    
    products_from_child_collection = Cornerstore::Product.by_collection(child_collection.id)
    
    enabled_products = Cornerstore::Product.enabled
    number_of_products_with_love = all_collections.first.products.enabled.by_keywords("love").count
    
    product = Cornerstore::Product.all.last
    first_variant = product.variants.first
    
    ten_popular_products = Cornerstore::Product.enabled.order('popularity').offset(20).limit(10)
  end
  
  def self.create_line_item_from_variant
    variant = Cornerstore::Product.all.last.variants.first
    cart = Cornerstore::Cart.create
    line_item = cart.line_items.create_from_variant(variant)
  end
  
  def self.update_line_item
    l = create_line_item_from_variant
    l.qty = 2
    l.save
  end
end
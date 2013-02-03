# Cornerstore

This is a client for the Cornerstore e-commerce API
    
## Usage

    all_collections = Cornerstore::Collection.all
    
    child_collection = Cornerstore::Collection.find("510bc93796c70bde5900005f").childs.first

    products_from_child_collection = child_collection.products    
    products_from_child_collection = Cornerstore::Product.by_collection(child_collection.id)
    
    enabled_products = Cornerstore::Product.enabled
    number_of_products_with_love = all_collections.first.products.enabled.by_keywords("love").count
    
    product = Cornerstore::Product.find("5107c57596c70bbb82000013")
    first_variant = product.variants.first
    
    ten_popular_products = Cornerstore::Product.enabled.order('popularity').offset(20).limit(10)
    
Someday someone should write some documentation
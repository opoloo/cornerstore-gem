class Cornerstore::Product < Cornerstore::Base
  attr_accessor :name,
                :description,
                :manufacturer, 
                :enabled,
                :variants
  
  def initialize(attributes = {}, parent=nil)
    self.variants = Cornerstore::Variant::Resource.new(self)
    if variants_attributes = attributes.delete('variants')
      self.variants.concat variants_attributes.map {|hash| Cornerstore::Variant.new(hash, self)}
    end
    super
  end
  
  def to_param
    "#{_id}-#{name.parameterize}"
  end
  
  class Resource < Cornerstore::Resource
    def enabled
      self.clone.set_filter(:enabled, true)
    end
    
    def by_collection(collection_id)
      # self.clone.set_filter(:collection_id, collection_id)
      self.clone.tap{|r| r.parent = Cornerstore::Collection.find(collection_id)}
    end
    alias find_by_collection by_collection
    
    def by_keywords(keywords)
      self.clone.set_filter(:keywords, keywords)
    end
    alias find_by_keywords by_keywords
    
    def order(key)
      first = %w(name popularity created_at price)
      second = %w(desc asc)
      pattern = /\A(#{first.join('|')})( (#{second.join('|')}))?\z/i
      raise "order key must be one of: #{first.join(', ')} [#{second.join(', ')}]" unless key.match pattern
      super
    end
    alias order_by order
    
    # def self.url_for_id(id)
    #   "#{Cornerstore.root_url}/products/#{id}.json"
    # end
        
    # def url_for_all
    #   if collection_id = @filters[:collection_id]
    #     "#{Cornerstore.root_url}/collections/#{collection_id}/products"
    #   else
    #     "#{Cornerstore.root_url}/products"
    #   end
    # end
    
    def query_string
      super(@filters.delete_if{|key| key == :collection_id})
    end   
  end
end
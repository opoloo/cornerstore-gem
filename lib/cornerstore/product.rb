class Cornerstore::Product < Cornerstore::Base
  attr_accessor :name,
                :description,
                :manufacturer, 
                :enabled,
                :variants
  
  def initialize(attributes = {})
    # Variants are nested
    if variants_attributes = attributes.delete('variants')
      self.variants = variants_attributes.map do |hash|
        variant = Cornerstore::Variant.new(hash)
        variant.product = self
        variant
      end
    end
    super
  end
  
  def to_param
    "#{_id}-#{name.parameterize}"
  end
  
  class Resource < Cornerstore::Resource
    def enabled
      resource = self.clone
      resource.set_filter(:enabled, true)
      resource
    end
    
    def by_collection(collection_id)
      resource = self.clone
      resource.set_filter(:collection_id, collection_id)
      resource
    end
    alias find_by_collection by_collection
    
    def by_keywords(keywords)
      resource = self.clone
      resource.set_filter(:keywords, keywords)
      resource
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
    
    private
    
    def url_for_all
      if collection_id = @filters[:collection_id]
        "#{Cornerstore.root_url}/collections/#{collection_id}/products.json"
      else
        "#{Cornerstore.root_url}/products.json"
      end
    end
    
    def query_string
      super(@filters.delete_if{|key| key == :collection_id})
    end   
  end
end
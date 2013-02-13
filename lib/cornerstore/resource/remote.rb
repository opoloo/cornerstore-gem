module Cornerstore::Resource::Remote
  attr_accessor :load
  
  def url(id = nil, depth = 1)
    root = (@parent && depth > 0) ? @parent.url(depth-1) : Cornerstore.root_url
    "#{root}/#{@name or @klass.name.split('::').last.underscore.pluralize}/#{id}"
  end
  
  def find_by_id(id)
    object = super
    object or fetch(id)
  end
  
  def fetch(id)
    response = RestClient.get(url(id))
    hash = ActiveSupport::JSON.decode(response)
    @klass.new(hash, @parent)
  end
  
  def fetch_all
    response = RestClient.get(url, params: @filters)  
    from_array ActiveSupport::JSON.decode(response)
  end
  
  def to_a
    fetch_all unless @load
    super
  end
end
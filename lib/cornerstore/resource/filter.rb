module Cornerstore::Resource::Filter
  def set_filter(key, value)
    @filters[key] = value
    self
  end
  
  def offset(offset)
    self.clone.set_filter(:offset, offset.to_i.abs)
  end
  
  def limit(limit)
    limit = limit.to_i.abs
    raise "limit must be greater/equal to 1" unless limit > 1
    self.clone.set_filter(:limit, limit)
  end
  
  def order(key)
    self.clone.set_filter(:order, key)
  end
  alias order_by order
end
module RestClient::AbstractResponse
  def success?
    (200..207).include? code
  end
end

class Cornerstore::Resource
  def initialize
    @klass = Cornerstore.const_get(self.class.name.split('::')[-2])
    @filters = Hash.new
    @objects = Array.new
  end
  
  def find(*args)
    ids = Array.new(args).flatten.compact.uniq
    case ids.size
      when 0
        raise "Couldn't find #{@klass.name} without an ID"
      when 1
        find_by_id_or_param(ids.first)
      else
        find_by_ids(ids)
    end
  end
  
  def find_by_id_or_param(id_or_param)
    find_by_id id_or_param.to_s.split("-").first
  end
  
  def find_by_id(id)
    @objects.find{|obj| obj._id == id} or load_id(id)
  end

  def find_by_ids(*args)
    ids = Array.new(args).flatten.compact.uniq
    all.select{|item| ids.include? item._id }
  end
  
  def all
    self.clone
  end
  
  def offset(offset)
    resource = self.clone
    resource.set_filter(:offset, offset.to_i.abs)
    resource
  end
  
  def limit(limit)
    limit = limit.to_i.abs
    raise "limit must be greater/equal to 1" unless limit > 1
    resource = self.clone
    resource.set_filter(:limit, limit)
    resource
  end
  
  def order(key)
    resource = self.clone
    resource.set_filter(:order, key)
    resource
  end
  alias order_by order
  
  def to_a
    load_all if @objects.empty?
    @objects
  end
  
  def to_url
    url_for_all + query_string
  end
  
  protected
      
  def url_for_id(id)
    "#{Cornerstore.root_url}/#{self.class.name.split('::')[-2].downcase.pluralize}/#{id}.json"
  end
  
  def url_for_all
    "#{Cornerstore.root_url}/#{self.class.name.split('::')[-2].downcase.pluralize}.json"
  end
  
  def query_string(filters=nil)
    filters ||= @filters
    '?' + filters.map{|key, value| "#{URI.encode(key.to_s)}=#{URI.encode(value.to_s)}"}.join('&')
  end
  
  def load_id(id)
    puts "\e[32mRequesting #{self.class.name.split('::')[-2]} with ID=#{id} from #{url_for_id(id)}\e[0m"
    response = RestClient.get(url_for_id(id))
    hash = ActiveSupport::JSON.decode(response)
    @klass.new(hash)
  end
  
  def load_all
    puts "\e[32mRequesting #{self.class.name.split('::')[-2].pluralize} from #{to_url}\e[0m"
    response = RestClient.get(to_url)  
    array = ActiveSupport::JSON.decode(response)
    @objects = array.map{|hash| @klass.new(hash)}
  end
  
  def set_filter(key, value)
    @filters[key] = value
  end
  
  def method_missing(method, *args, &block)
    if Array.method_defined?(method)
      to_a.send(method, *args, &block)
    else
      super
    end
  end
end
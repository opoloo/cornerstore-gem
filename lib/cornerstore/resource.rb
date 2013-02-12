class Cornerstore::Resource
  def initialize(parent=nil)
    @klass = Cornerstore.const_get(self.class.name.split('::')[-2])
    @parent = parent
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
  
  def to_a
    load_all if @objects.empty?
    @objects
  end
  
  def first!
    to_a.first
  end
  
  def last!
    to_a.last
  end
  
  def url_for_id(id)
    if @parent
      "#{@parent.url}/#{self.class.name.split('::')[-2].underscore.pluralize}/#{id}"
    else
      raise "This resource needs a parent" if self.class.const_defined?('NESTED') and not @parent
      "#{Cornerstore.root_url}/#{self.class.name.split('::')[-2].underscore.pluralize}/#{id}"
    end
  end
  
  def url_for_all
    if @parent
      "#{@parent.url}/#{self.class.name.split('::')[-2].underscore.pluralize}"
    else
      raise "This resource needs a parent" if self.class.const_defined?('NESTED') and not @parent
      "#{Cornerstore.root_url}/#{self.class.name.split('::')[-2].underscore.pluralize}"      
    end
  end
  
  def query_string(filters=nil)
    filters ||= @filters
    '?' + filters.map{|key, value| "#{URI.encode(key.to_s)}=#{URI.encode(value.to_s)}"}.join('&')
  end
  
  def load_id(id)
    puts "\e[32mRequesting #{self.class.name.split('::')[-2]} with ID=#{id} from #{url_for_id(id)}\e[0m"
    response = RestClient.get(url_for_id(id))
    hash = ActiveSupport::JSON.decode(response)
    @klass.new(hash, @parent)
  end
  
  def load_all
    puts "\e[32mRequesting #{self.class.name.split('::')[-2].pluralize} from #{url_for_all + query_string}\e[0m"
    response = RestClient.get(url_for_all + query_string)  
    array = ActiveSupport::JSON.decode(response)
    @objects = array.map{|hash| @klass.new(hash, @parent)}
  end
  
  def set_filter(key, value)
    @filters[key] = value
    self
  end
  
  def <<(obj)
    @objects << obj
    obj.parent = @parent
    self
  end
  alias_method :push, :<<
  
  def concat(ary)
    ary.each{|obj| push obj }
  end
  
  def new
    raise "Sorry, this part of the Cornerstore-API is currently read-only"
  end
  
  def create
    raise "Sorry, this part of the Cornerstore-API is currently read-only"
  end
  
  def method_missing(method, *args, &block)
    if Array.method_defined?(method)
      to_a.send(method, *args, &block)
    else
      super
    end
  end
end

class Cornerstore::WritableResource < Cornerstore::Resource
  def destroy_all
    @objects.delete_if {|obj| obj.destroy}
    self
  end
  
  def new(attributes={}, &block)
    obj = @klass.new(attributes, &block)
    push obj
    obj
  end
  
  def create(attributes={}, &block)
    attributes['parent'] = @parent
    obj = @klass.new(attributes, &block)
    if obj.save
      push obj
      obj
    else
      nil
    end
  end
end
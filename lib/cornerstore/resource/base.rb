class Cornerstore::Resource::Base
  attr_accessor :parent
  
  def initialize(parent = nil, ary = nil, name = nil)
    @klass = Cornerstore.const_get(self.class.name.split('::')[-2])
    @name = name
    @parent = parent
    @filters = Hash.new
    @objects = Array.new
    from_array(ary) if ary
  end
  
  def from_array(ary)
    @objects = ary.map{|h| @klass.new(h, @parent)}
    @load = true
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
    @objects.find{|obj| obj._id == id}
  end
  
  def find_by_ids(*args)
    ids = Array.new(args).flatten.compact.uniq
    all.select{|item| ids.include? item._id }
  end
  
  def all
    self.clone
  end
  
  def push(obj)
    @objects << obj
    obj.parent = @parent
    self
  end
  alias_method :<<, :push
  
  def to_a
    @objects
  end
  
  def method_missing(method, *args, &block)
    if Cornerstore::Resource::Writable.method_defined?(method)
      raise "Sorry, this part of the Cornerstore-API is currently read-only"
    elsif Array.method_defined?(method)
      to_a.send(method, *args, &block)
    else
      super
    end
  end
end
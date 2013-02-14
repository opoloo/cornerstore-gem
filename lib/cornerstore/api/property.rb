class Cornerstore::Property < Cornerstore::Model::Base
  attr_accessor :key,
                :value
  
  def attributes
    {
      key: key,
      value: value
    }
  end
  
  class Resource < Cornerstore::Resource::Base
  end
end
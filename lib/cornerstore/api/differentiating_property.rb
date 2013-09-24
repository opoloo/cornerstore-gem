class Cornerstore::DifferentiatingProperty < Cornerstore::Model::Base
  attr_accessor :key,
                :value
  
  def attributes
    {
      hide_from: hide_from,
      key: key,
      value: value
    }
  end
  
  class Resource < Cornerstore::Resource::Base
  end
end
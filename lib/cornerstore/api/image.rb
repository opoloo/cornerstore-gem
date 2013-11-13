class Cornerstore::Image < Cornerstore::Model::Base
  attr_accessor :cover,
                :size,
                :format,
                :height,
                :width,
                :key


  alias content_type format
  alias file_size size

  # small, small_square, medium, medium_square, large
  def url(w=600, h=600)
    #ext = file_file_name.split('.').last
    #{}"#{Cornerstore.assets_url}/product_images/#{_id}/#{size}.#{ext}"
    "http://res.cloudinary.com/hgzhd1stm/image/upload/c_scale,h_#{h},w_#{w}/#{self.key}"
  end

  class Resource < Cornerstore::Resource::Base
  end
end
class Cornerstore::Image < Cornerstore::Model::Base
  attr_accessor :cover,
                :file_file_size,
                :file_content_type,
                :file_file_name

  alias content_type file_content_type
  alias file_size file_file_size

  # small, small_square, medium, medium_square, large
  def url(size = :medium)
    ext = file_file_name.split('.').last
    "#{Cornerstore.assets_url}/product_images/#{_id}/#{size}.#{ext}"
  end

  class Resource < Cornerstore::Resource::Base
  end
end
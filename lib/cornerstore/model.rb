module Cornerstore
  module Model
    class Base
      include ActiveModel::Validations

      attr_accessor :_id
      attr_accessor :parent

      def id
        _id
      end
      alias to_param id

      def ==(other)
        other.id == self.id
      end
      alias eql? ==

      def inspect
        {class: self.class.name, id: id}.merge!(attributes).to_s
      end

      def initialize(attributes = {}, parent = nil)
        self.attributes = attributes
        self.parent = parent
        yield self if block_given?
      end

      def attributes
        {}
      end

      def attributes=(attributes)
        attributes ||= {}
        attributes.each do |name, value|
          send("#{name}=", value) if respond_to?("#{name}=")
        end
      end

      def url(depth = 1)
        root = (@parent && depth > 0) ? @parent.url(depth-1) : Cornerstore.root_url
        "#{root}/#{self.class.name.split('::').last.underscore.pluralize}/#{id}"
      end

      def self.method_missing(method, *args, &block)
        if (self.const_defined?("Resource") and self.const_get("Resource").method_defined?(method)) or Array.method_defined?(method)
          self.const_get("Resource").new.send(method, *args, &block)
        else
          super
        end
      end

      def method_missing(method, *args, &block)
        if Writable.method_defined?(method)
          raise "Sorry, this part of the Cornerstore-API is currently read-only"
        else
          super
        end
      end
    end

    module Writable
      def new?
        id.nil?
      end

      def to_key
        new? ? [id] : nil
      end

      def save
        return false unless valid?
        wrapped_attributes = {self.class.name.split('::').last.underscore => self.attributes}
        if new?
          response = RestClient.post(url, wrapped_attributes){|response| response}
          self.attributes = ActiveSupport::JSON.decode(response)
        else
          response = RestClient.patch(url, wrapped_attributes){|response| response}
        end
        response.success?
      end

      def destroy
        RestClient.delete(url).success?
      end

      def self.create(attributes = {}, &block)
        self.new(attributes, &block).tap{|obj| obj.save}
      end
    end
  end
end
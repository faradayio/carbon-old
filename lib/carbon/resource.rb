require 'uri'
require 'json'

module Carbon
  module Resource
    class << self
      def included(target)
        if target == Carbon::Emitter
          Carbon::Emitter::ClassMethods.instance_eval { include(Carbon::Resource::ClassMethods) }
        else
          target.extend(Carbon::Resource::ClassMethods)
        end
      end

      def underscore(string)
        string.gsub(/([a-z])([A-Z])/,'\1_\2').downcase
      end
    end


    module ClassMethods
      def resource_name(val = nil)
        @resource_name = val.to_s unless val.nil?
        if @resource_name.nil?
          class_name = self.to_s.split('::').last
          @resource_name ||= "#{Carbon::Resource.underscore(class_name)}s"
        end
        @resource_name
      end
    end

  private
    attr_accessor :result

    def fields
      self.class.characteristics.map(&:to_s).inject({}) do |hash, char|
        value = self.send(char)
        if value.respond_to?(:keys)
          hash[char] = {}
          value.each do |key, value|
            hash[char][key.to_s] = value
          end
        elsif !value.nil?
          hash[char] = value
        end
        hash
      end
    end

    def resource
      url = URI.join(Carbon.base_url, self.class.resource_name)
      @resource ||= RestClient::Resource.new(url.to_s)
    end

    def fetch_calculation
      response = resource.post fields, :accept => :json
      self.result = JSON.parse(response.body)
    end
  end
end

require 'uri'
require 'rest_client'
require 'active_support'

module Carbon
  class EmissionsCalculation
    class NotYetCalculated < StandardError; end

    attr_accessor :options, :source, :value, :methodology_url

    def initialize(options, source)
      self.options = options
      self.source = source
    end

    def methodology_url
      raise NotYetCalculated if result.nil?
      @methodology_url
    end
    def value
      raise NotYetCalculated if result.nil?
      @value
    end

    def calculate!
      fetch_calculation
      @value = result['emission']
      @methodology_url = result['methodology']
    end

  private
    def result
      @result
    end

    def resource
      url = URI.join(Carbon.base_url, options.emitter_type.to_s.pluralize)
      @resource ||= RestClient::Resource.new(url.to_s)
    end

    def fields
      options.characteristics.inject({}) do |hsh, characteristic|
        hsh[characteristic.name] = source.send(characteristic.field)
        hsh
      end
    end

    def fetch_calculation
      response = resource.post fields, :accept => :json
      @result = JSON.parse(response.body)
    end
  end
end

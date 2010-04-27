require 'uri'
require 'active_support/inflector'
require 'net/http'

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

    def fields
      options.characteristics.inject({}) do |hsh, characteristic|
        hsh[characteristic.name] = source.send(characteristic.field)
        hsh
      end
    end

    def fetch_calculation
      url = URI.join(Carbon.base_url, options.emitter_type.to_s.pluralize)
      request = Net::HTTP::Post.new(url.path, 'Accept' => 'application/json')
      request.set_form_data(fields)
      response = Net::HTTP.new(url.host).start { |http| http.request(request) }

      @result = JSON.parse(response.body)
    end
  end
end

require 'uri'
require 'active_support/inflector'
require 'httparty'

module Carbon
  class EmissionsCalculation
    class NotYetCalculated < StandardError; end
    class CalculationRequestFailed < StandardError; end

    include HTTParty

    attr_accessor :options, :source
    attr_reader :value, :methodology_url, :committees

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
      @committees = result['committees']
    end

  private
    def result
      @result
    end

    def fields
      fields_hash = options.characteristics.inject({}) do |hsh, characteristic|
        value = source.send(characteristic.field)
        hsh[characteristic.name.to_sym] = value if value
        hsh
      end
      { :body => { options.emitter_type => fields_hash } }
    end

    def fetch_calculation
      url = URI.join(Carbon.base_url, options.emitter_type.to_s.pluralize)
      options = fields.merge(:headers => { 'Accept' => 'application/json' }) 
      response = self.class.post(url.to_s, options)

      unless (200..399).include?(response.code)
        raise CalculationRequestFailed, response.body
      end

      puts response.body if Carbon.debug

      @result = JSON.parse(response.body)
    end
  end
end

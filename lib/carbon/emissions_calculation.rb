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

    def fields(emitter_options = options)
      fields_hash = emitter_options.characteristics.inject({}) do |hsh, characteristic|
        if characteristic.respond_to?(:characteristics)
          sub_hash = fields(characteristic)
          sub_hash[characteristic.name.to_sym].empty? ? hsh : hsh.merge(sub_hash)
        else
          value = source.send(characteristic.field)
          hsh[characteristic.name.to_sym] = value if value
          hsh
        end
      end
      { emitter_options.name.to_sym => fields_hash }
    end

    def fetch_calculation
      url = URI.join(Carbon.base_url, options.name.to_s.pluralize)
      response = self.class.post(url.to_s,
        :headers => { 'Accept' => 'application/json' },
        :body => fields
      )

      unless (200..399).include?(response.code)
        raise CalculationRequestFailed, response.body
      end

      puts response.body if Carbon.debug

      @result = JSON.parse(response.body)
    end
  end
end

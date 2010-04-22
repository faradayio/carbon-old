module Carbon
  module Emitter
    class NotYetCalculated < StandardError; end

    attr_accessor :methodology_url
    attr_reader :footprint
    
    def methodology_url
      raise Emitter::NotYetCalculated if footprint.nil?
      @methodology_url
    end

    def calculate!
      @footprint = 0
      @methodology_url = 'http://carbon.brighterplanet.com'
    end
  end
end

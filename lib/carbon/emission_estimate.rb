require 'carbon/emission_estimate/response'
require 'carbon/emission_estimate/request'

module Carbon
  # Let's start off by saying that <tt>EmissionEstimate</tt> objects quack like numbers.
  #
  # So, you can just say <tt>my_car.emission</tt> and you'll get something like <tt>4308.29</tt>.
  #
  # At the same time, they contain all the data you get back from the emission estimate web service. For example, you could say <tt>puts my_donut_factor.emission.oven_count</tt> (see the tests) and you'd get back the oven count used in the calculation, if any.
  # 
  # Note: <b>you need to take care of storing emission estimates to local variables!</b> The gem doesn't cache these for you. Every time you call <tt>emission</tt> it will send another query to the server!
  class EmissionEstimate
    def initialize(emitter)
      @emitter = emitter
    end
    
    VALID_OPTIONS = [:callback_content_type, :key, :callback, :timeframe]
    def take_options(options)
      return if options.blank?
      options.slice(*VALID_OPTIONS).each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end

    # I can be compared directly to a number.
    def ==(other)
      case other
      when Numeric
        other == response.number
      else
        super
      end
    end

    # You can ask an EmissionEstimate object for any of the response data provided.
    # This is useful for characteristics that are unique to an emitter.
    #
    # For example:
    #   > my_car.emission.model
    #   => 'Ford Taurus'
    def method_missing(method_id, *args, &blk)
      if !block_given? and args.empty? and response.data.has_key? method_id.to_s
        response.data[method_id.to_s]
      elsif response.number.respond_to? method_id
        response.number.send method_id, *args, &blk
      else
        super
      end
    end

    attr_writer :callback_content_type
    attr_writer :key

    attr_accessor :callback
    attr_accessor :timeframe
    
    attr_reader :emitter
    def request
      @request ||= Request.new self
    end
    # Here's where caching takes place.
    def response
      current_params = request.params
      @response ||= {}
      return @response[current_params] if @response.has_key? current_params
      @response[current_params] = Response.new self
    end
    def mode
      callback ? :async : :realtime
    end
    def callback_content_type
      @callback_content_type || 'application/json'
    end
    def key
      @key || ::Carbon.key
    end
    # Another way to access the emission value.
    # Useful if you don't like treating <tt>EmissionEstimate</tt> objects like <tt>Numeric</tt> objects (even though they do quack like numbers...)
    def emission_value
      response.number
    end
    # The units of the emission.
    def emission_units
      response.data['emission_units']
    end
    # Errors (and warnings) as reported in the response.
    # Note: may contain HTML tags like KBD or A
    def errors
      response.data['errors']
    end
    # The URL of the methodology report indicating how this estimate was calculated.
    #   > my_car.emission.methodology
    #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
    def methodology
      response.data['methodology']
    end
  end
end

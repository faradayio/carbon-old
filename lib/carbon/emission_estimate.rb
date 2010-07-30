require 'carbon/emission_estimate/response'
require 'carbon/emission_estimate/request'
require 'carbon/emission_estimate/storage'

module Carbon
  # Let's start off by saying that realtime <tt>EmissionEstimate</tt> objects quack like numbers.
  #
  # If you ask for a callback, on the other hand, you can't use them as numbers.
  #
  # So, you can just say <tt>my_car.emission_estimate.to_s</tt> and you'll get something like <tt>"4308.29"</tt>.
  #
  # At the same time, they contain all the data you get back from the emission estimate web service. For example, you could say <tt>puts my_donut_factor.emission_estimate.oven_count</tt> (see the tests) and you'd get back the oven count used in the calculation, if any.
  class EmissionEstimate
    def self.parse(str)
      data = ::ActiveSupport::JSON.decode str
      data['active_subtimeframe'] = ::Timeframe.interval(data['active_subtimeframe']) if data.has_key? 'active_subtimeframe'
      data['updated_at'] = ::Time.parse(data['updated_at']) if data.has_key? 'updated_at'
      data
    end
    
    def initialize(emitter)
      @emitter = emitter
    end
    
    VALID_OPTIONS = [:callback_content_type, :key, :callback, :timeframe, :guid, :timeout, :defer]
    def take_options(options)
      return if options.blank?
      options.slice(*VALID_OPTIONS).each do |k, v|
        instance_variable_set "@#{k}", v
      end
    end

    # I can be compared directly to a number, unless I'm an async request.
    def ==(other)
      if other.is_a? ::Numeric and mode == :realtime
        other == number
      else
        super
      end
    end

    # You can ask an EmissionEstimate object for any of the response data provided.
    # This is useful for characteristics that are unique to an emitter.
    #
    # For example:
    #   > my_car.emission_estimate.model
    #   => 'Ford Taurus'
    def method_missing(method_id, *args, &blk)
      if !block_given? and args.empty? and data.has_key? method_id.to_s
        data[method_id.to_s]
      elsif ::Float.method_defined? method_id
        raise TriedToUseAsyncResponseAsNumber if mode == :async
        number.send method_id, *args, &blk
      else
        super
      end
    end
    attr_writer :callback_content_type
    attr_writer :key
    attr_writer :timeout
    attr_writer :defer
    attr_accessor :callback
    attr_accessor :timeframe
    attr_accessor :guid
    attr_reader :emitter
    def data
      if storage.present?
        storage.data
      else
        response.data
      end
    end
    def storage
      @storage ||= {}
      return @storage[guid] if @storage.has_key? guid
      @storage[guid] = Storage.new self
    end
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
    def defer?
      @defer == true
    end
    def async?
      callback or defer?
    end
    def mode
      async? ? :async : :realtime
    end
    # Timeout on realtime requests in seconds, if desired.
    def timeout
      @timeout
    end
    def callback_content_type
      @callback_content_type || 'application/json'
    end
    def key
      @key || ::Carbon.key
    end
    # The timeframe being looked at in the emission calculation.
    def active_subtimeframe
      data['active_subtimeframe']
    end
    # Another way to access the emission value.
    # Useful if you don't like treating <tt>EmissionEstimate</tt> objects like <tt>Numeric</tt> objects (even though they do quack like numbers...)
    def number
      async? ? nil : data['emission'].to_f.freeze
    end
    # The units of the emission.
    def emission_units
      data['emission_units']
    end
    # Errors (and warnings) as reported in the response.
    # Note: may contain HTML tags like KBD or A
    def errors
      data['errors']
    end
    # The URL of the methodology report indicating how this estimate was calculated.
    #   > my_car.emission_estimate.methodology
    #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
    def methodology
      data['methodology']
    end
  end
end

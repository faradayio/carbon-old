require 'uri'
require 'blockenspiel'
require 'rest' # provided by nap gem
require 'timeframe'
%w{
  active_support/core_ext/module/attribute_accessors
  active_support/core_ext/class/attribute_accessors
  active_support/core_ext/hash/keys
  active_support/core_ext/hash/reverse_merge
  active_support/core_ext/object/to_query
  active_support/core_ext/array/wrap
  active_support/inflector/inflections
  active_support/json/decoding
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end
require 'carbon/base'
require 'carbon/emission_estimate'

# A module (aka mixin) that lets you estimate carbon emissions by querying the {Brighter Planet carbon middleware emission estimate web service}[http://carbon.brighterplanet.com].
#
#   class RentalCar
#     include Carbon
#     [...]
#     emit_as :automobile do
#       provide :make
#       provide :model
#       provide :model_year
#     end
#   end
#
# The DSL consists of the methods <tt>emit_as</tt> and <tt>provide</tt>.
#
# In this example, the DSL says:
# * A rental car emits carbon like an "automobile", which is one of Brighter Planet's recognized emitter classes.
# * Your implementation can provide up to three data points about a rental car: its make, its model, and its model year (but not necessarily all of them, all the time.)
#
# Once you've mixed in <tt>Carbon</tt>, you get the method <tt>emission</tt>, which you can call at any time to request an emission estimate.
module Carbon
  def self.included(klass) # :nodoc:
    klass.cattr_accessor :carbon_base
    klass.extend ClassMethods
  end
  
  REALTIME_URL = 'http://carbon.brighterplanet.com'
  ASYNC_URL = 'https://queue.amazonaws.com/121562143717/cm1_production_incoming'
  
  class BlankCallback < ArgumentError # :nodoc:
  end
  class RealtimeEstimateFailed < RuntimeError # :nodoc:
  end
  class QueueingFailed < RuntimeError # :nodoc:
  end
  class RateLimited < RuntimeError # :nodoc:
  end

  # The api key obtained from http://keys.brighterplanet.com
  mattr_accessor :key
    
  def self.prepare_options(options) # :nodoc:
    options[:key] ||= key
    options[:mode] ||= options.has_key?(:callback) ? :async : :realtime
  end

  # You will probably never access this module directly. Instead, you'll use it through the DSL.
  #
  # It's mixed into any class that includes <tt>Carbon</tt>.
  module ClassMethods
    # Indicate that this class "emits as" an <tt>:automobile</tt>, <tt>:flight</tt>, or another of the Brighter Planet emitter classes.
    #
    # See the {emission estimate web service use documentation}[http://carbon.brighterplanet.com/use]
    #
    # For example,
    #   emit_as :automobile do
    #     provide :make
    #   end
    def emit_as(emitter_common_name, &block)
      self.carbon_base ||= ::Carbon::Base.new self, emitter_common_name
      ::Blockenspiel.invoke block, carbon_base
    end
    # japanese-style preferred
    alias :emits_as :emit_as
  end
  
  # Used internally, but you can look if you want.
  #
  # Returns the URL to which emissions estimate queries will be POSTed.
  #
  # For example:
  #   > my_car._carbon_request_url
  #   => 'http://carbon.brighterplanet.com/automobiles.json'
  def _carbon_request_url(options = {})
    ::Carbon.prepare_options options
    send "_#{options[:mode]}_carbon_request_url"
  end
  
  def _realtime_carbon_request_url # :nodoc:
    "#{::Carbon::REALTIME_URL}/#{self.class.carbon_base.emitter_common_name.pluralize}.json"
  end
  
  def _async_carbon_request_url # :nodoc:
    ::Carbon::ASYNC_URL
  end
  
  # Used internally, but you can look if you want.
  #
  # Returns the request body that will be posted.
  #
  # For example:
  #   > my_car._carbon_request_body
  #   => 'fuel_efficiency=41&model=Ford+Taurus'
  def _carbon_request_body(options = {})
    ::Carbon.prepare_options options
    send "_#{options[:mode]}_carbon_request_body", options
  end

  def _async_carbon_request_body(options) # :nodoc:
    params = _carbon_request_params options
    params[:emitter] = self.class.carbon_base.emitter_common_name
    raise ::Carbon::BlankCallback unless options[:callback].present?
    params[:callback] = options[:callback]
    params[:callback_content_type] = options[:callback_content_type] || 'application/json'
    {
      :Action => 'SendMessage',
      :Version => '2009-02-01',
      :MessageBody => params.to_query
    }.to_query
  end

  def _realtime_carbon_request_body(options) # :nodoc:
    _carbon_request_params(options).to_query
  end
  
  # Used internally, but you can look if you want.
  #
  # Returns the params hash that will be send to the emission estimate server.
  def _carbon_request_params(options)
    ::Carbon.prepare_options options
    params = self.class.carbon_base.translation_table.inject(Hash.new) do |memo, translation|
      characteristic, as = translation
      current_value = send as
      if current_value.present?
        if characteristic.is_a? Array                                 # [:mixer, :size]
          memo[characteristic[0]] ||= Hash.new                        # { :mixer => Hash.new }
          memo[characteristic[0]][characteristic[1]] = current_value  # { :mixer => { :size => 'foo' }}
        else                                                          # :oven_count
          memo[characteristic] = current_value                        # { :oven_count => 'bar' }
        end
      end
      memo
    end
    params.merge! options.slice(:timeframe, :key)
    params
  end

  def _realtime_emission(options = {}) # :nodoc:
    attempts = 0
    begin
      response = _carbon_response options
      raise ::Carbon::RateLimited if response.status_code == 403 and response.body =~ /Rate Limit/i
    rescue ::Carbon::RateLimited
      if attempts < 4
        attempts += 1
        sleep 0.2 * attempts
        retry
      else
        raise $!, "Rate limited #{attempts} time(s) in a row"
      end
    end
    raise ::Carbon::RealtimeEstimateFailed unless response.success?
    ::Carbon::EmissionEstimate.new ::ActiveSupport::JSON.decode(response.body)
  end
  
  def _async_emission(options = {}) # :nodoc:
    response = _carbon_response options
    raise ::Carbon::QueueingFailed unless response.success?
    true
  end
    
  # Used internally, but you can look if you want.
  #
  # Runs the query and returns the raw response body, which will be in JSON.
  #
  # For example:
  #   > my_car._carbon_response.body
  #   => "{ 'emission' => 410.29, 'emission_units' => 'kilograms', [...] }"
  def _carbon_response(options = {})
    @last_carbon_request = ::REST::Request.new :post, ::URI.parse(_carbon_request_url(options)), _carbon_request_body(options), {'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'}
    @last_carbon_response = @last_carbon_request.perform
  end
  
  # Returns an object representing the last emission estimate request.
  def last_carbon_request
    @last_carbon_request
  end
  
  # Returns an object representing the last emission estimate response.
  def last_carbon_response
    @last_carbon_response
  end

  # Returns an emission estimate.
  #
  # Note: <b>You need to take care of storing the return value to a local variable!</b> Every call to <tt>emission</tt> runs a query.
  #
  # Note also: please see the README about exceptions that you should watch out for.
  # 
  # You can use it like a number...
  #   > my_car.emission + 5.1
  #   => 415.39
  # Or you can get information about the response
  #   > my_car.emission.methodology
  #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
  #
  # === Options:
  #
  # * <tt>:timeframe</tt> (optional) pass an instance of Timeframe[http://github.com/rossmeissl/timeframe] to request an emission for a specific time period.
  # * <tt>:callback</tt> (optional) where to POST the result when it's been calculated. You need a server waiting for it!
  # * <tt>:callback_content_type</tt> (optional if <tt>:callback</tt> is specified, ignored otherwise) pass a MIME type like 'text/yaml' so we know how to format the result when we send it to your waiting server. Defaults to 'application/json'.
  # * <tt>:key</tt> (optional, overrides general <tt>Carbon</tt>.<tt>key</tt> setting just for this query) If you want to use different API keys for different queries.
  def emission(options = {})
    ::Carbon.prepare_options options
    send "_#{options[:mode]}_emission", options
  end
end

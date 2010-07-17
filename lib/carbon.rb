require 'uri'
require 'blockenspiel'
require 'rest' # provided by nap gem
require 'andand'
require 'timeframe'
%w{
  active_support/core_ext/module/attribute_accessors
  active_support/core_ext/class/attribute_accessors
  active_support/core_ext/hash/keys
  active_support/core_ext/object/to_query
  active_support/core_ext/array/wrap
  active_support/inflector/inflections
  active_support/json
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end
require 'carbon/base'
require 'carbon/emission_estimate'

# A module (aka mixin) that lets you calculate carbon emission estimates using the {Brighter Planet carbon middleware emission estimate web service}[http://carbon.brighterplanet.com].
#
#   class RentalCar
#     include Carbon
#     attr_accessor :model
#     attr_accessor :model_year
#     attr_accessor :fuel_economy
#     emit_as :automobile do
#       provide :make
#       provide :model
#       provide :model_year
#     end
#   end
module Carbon
  DEFAULT_BASE_URL = 'http://carbon.brighterplanet.com'
  REQUEST_HEADERS = {
    'Accept' => 'application/json, */*',
    'Content-Type' => 'application/x-www-form-urlencoded; charset=utf-8'
  }
  mattr_accessor :key
  mattr_accessor :base_url
  self.base_url = DEFAULT_BASE_URL
  def self.included(klass) # :nodoc:
    klass.cattr_accessor :carbon_base
    klass.extend ClassMethods
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
  def _carbon_request_url
    return @_carbon_request_url[::Carbon.base_url] if @_carbon_request_url.andand.has_key? ::Carbon.base_url
    @_carbon_request_url ||= ::Hash.new
    url = ::URI.parse ::Carbon.base_url
    url.path = "/#{self.class.carbon_base.emitter_common_name.pluralize}.json"
    @_carbon_request_url[::Carbon.base_url] = url.to_s
  end
  
  # Used internally, but you can look if you want.
  #
  # Returns the request body that will be posted.
  #
  # For example:
  #   > my_car._carbon_request_body
  #   => 'fuel_efficiency=41&model=Ford+Taurus'
  #
  # We're **sending** using x-www-form-urlencoded because serializing objects into json is still troublesome. Why bother?
  #
  # Here's what to_query does...
  #
  #   ruby-1.8.7-head > { :make => { :name => 'Nissan' } }.to_param
  #    => "make[name]=Nissan" 
  #   ruby-1.8.7-head > { :name => 'Nissan' }.to_query(:make)
  #    => "make[name]=Nissan" 
  def _carbon_request_body
    self.class.carbon_base.translation_table.map do |characteristic, as|
      current_value = send(as)
      next if current_value.blank?
      if characteristic.is_a? Array #[:mixer, :size]
        { characteristic[1] => current_value }.to_query characteristic[0]
      else
        current_value.to_query characteristic
      end
    end.join '&'
  end
  
  # Used internally, but you can look if you want.
  #
  # Runs the query and returns the raw response body, which will be in JSON.
  #
  # For example:
  #   > my_car._carbon_response_body
  #   => "{ 'emission' => 410.29, 'emission_units' => 'kilograms', [...] }"
  def _carbon_response_body
    ::REST.post(_carbon_request_url, _carbon_request_body, ::Carbon::REQUEST_HEADERS).body
  end
  
  # Returns an emission estimate.
  #
  # You can use it like a number...
  #   > my_car.emission + 5.1
  #   => 415.39
  # Or you can get information about the response
  #   > my_car.emission.methodology
  #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
  def emission
    @emission ||= ::Carbon::EmissionEstimate.new ::ActiveSupport::JSON.decode(_carbon_response_body)
  end
end

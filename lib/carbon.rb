require 'uri'
require 'blockenspiel'
require 'timeframe'
require 'digest/sha1'
require 'rest'    # provided by nap gem
require 'active_support'
require 'active_support/version'
%w{
  active_support/core_ext/module/attribute_accessors
  active_support/core_ext/class/attribute_accessors
  active_support/core_ext/hash/keys
  active_support/core_ext/hash/reverse_merge
  active_support/core_ext/object/to_query
  active_support/inflector
  active_support/inflector/inflections
  active_support/json/decoding
}.each do |active_support_3_requirement|
  require active_support_3_requirement
end if ActiveSupport::VERSION::MAJOR == 3

require 'carbon/base'
require 'carbon/emission_estimate'
require 'logger'

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
# Once you've mixed in <tt>Carbon</tt>, you get the method <tt>emission_estimate</tt>, which you can call at any time to request an emission estimate.
module Carbon
  def self.included(klass) # :nodoc:
    klass.cattr_accessor :carbon_base
    klass.extend ClassMethods
  end
  
  class RealtimeEstimateFailed < RuntimeError # :nodoc:
  end
  class QueueingFailed < RuntimeError # :nodoc:
  end
  class RateLimited < RuntimeError # :nodoc:
  end
  class TriedToUseAsyncResponseAsNumber < RuntimeError # :nodoc:
  end

  # The api key obtained from http://keys.brighterplanet.com
  mattr_accessor :key

  mattr_accessor :log

  def self.log #:nodoc:
    @log ||= Logger.new STDOUT
  end
  
  def self.warn(msg) #:nodoc:
    log.warn msg
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
      self.carbon_base = ::Carbon::Base.new self, emitter_common_name
      ::Blockenspiel.invoke block, carbon_base
    end
    # Third-person singular preferred.
    alias :emits_as :emit_as
  end

  # Returns an emission estimate.
  #
  # Note: please see the README about <b>exceptions that you should watch out for</b>.
  # 
  # You can use it like a number...
  #   > my_car.emission_estimate + 5.1
  #   => 415.39
  # Or you can get information about the response
  #   > my_car.emission_estimate.methodology
  #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
  #
  # === Options:
  #
  # * <tt>:timeframe</tt> (optional) pass an instance of Timeframe[http://github.com/rossmeissl/timeframe] to request an emission for a specific time period.
  # * <tt>:callback</tt> (optional) where to POST the result when it's been calculated. You need a server waiting for it!
  # * <tt>:callback_content_type</tt> (optional if <tt>:callback</tt> is specified, ignored otherwise) pass a MIME type like 'text/yaml' so we know how to format the result when we send it to your waiting server. Defaults to 'application/json'.
  # * <tt>:key</tt> (optional, overrides general <tt>Carbon</tt>.<tt>key</tt> setting just for this query) If you want to use different API keys for different queries.
  def emission_estimate(options = {})
    @emission_estimate ||= ::Carbon::EmissionEstimate.new self
    @emission_estimate.take_options options
    @emission_estimate
  end
end

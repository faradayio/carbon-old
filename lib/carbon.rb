require 'uri'
require 'blockenspiel'
require 'timeframe'
require 'digest/sha1'
require 'rest'    # provided by nap gem
require 'active_support'
require 'active_support/version'

if ActiveSupport::VERSION::MAJOR >= 3
  require 'active_support/core_ext'
  require 'active_support/inflector'
  require 'active_support/inflector/inflections'
  require 'active_support/json/decoding'
end

require 'logger'

require 'carbon/classic_api'
require 'carbon/emission_estimate'
require 'carbon/registry'

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
  def self.included(target) # :nodoc:
    target.send :include, Carbon::ClassicAPI
  end

  def self.calculate(model, params)

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

  # Returns an emission estimate.
  #
  # Note: please see the README about <b>exceptions that you should watch out for</b>.
  #
  # Usage:
  #
  #   class RentalCar
  #     include Carbon
  #
  #     emit_as :automobile
  #   end
  #   
  #   my_car = RentalCar.new
  #   my_car.emission_estimate
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

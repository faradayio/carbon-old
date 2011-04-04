require 'rubygems'
require 'bundler'
Bundler.setup
require 'rspec'
require 'active_support/json/encoding'
require 'fakeweb'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'carbon'

Carbon.log = Logger.new nil

class RentalCar
  include Carbon
  attr_accessor :model, :model_year, :fuel_economy
  class Make
    attr_accessor :name
    def to_param
      name
    end
  end
  def make
    @make ||= Make.new
  end
  emit_as :automobile_trip do
    provide :make
    provide :model
    provide :model_year
    provide :fuel_economy, :as => :fuel_efficiency
  end
end

class DonutFactory
  include Carbon
  attr_accessor :smokestack_size, :oven_count, :employees
  class Mixer
    attr_accessor :upc
    def to_param
      raise "Use #to_characteristic instead please"
    end
    def to_characteristic
      upc
    end
  end
  def mixer
    @mixer ||= Mixer.new
  end
  emit_as :factory do
    provide :smokestack_size
    provide :oven_count
    provide :employees, :as => :personnel
    provide :mixer, :key => :upc
  end
end

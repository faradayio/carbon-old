$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'aruba/cucumber'
require 'fileutils'
require 'rspec/expectations'
require 'carbon'
require 'conversions'

Before do
  @aruba_io_wait_seconds = 2
  @aruba_timeout_seconds = 5
  @dirs = [File.join(ENV['HOME'], 'carbon_features')]
end

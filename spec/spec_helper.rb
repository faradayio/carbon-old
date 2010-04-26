carbon_path = File.expand_path(File.dirname(__FILE__) + '/../lib/')
$LOAD_PATH.unshift(carbon_path) unless $LOAD_PATH.include?(carbon_path)
require 'carbon'

require 'rubygems'
require 'spec'
require 'fakeweb'

Dir.glob(File.expand_path(File.dirname(__FILE__) + '/lib/**/*_examples.rb')).each do |file|
  require file
end

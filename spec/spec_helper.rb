require 'rubygems'
require 'spec'

carbon_path = File.expand_path(File.dirname(__FILE__) + '/../lib/')
$LOAD_PATH.unshift(carbon_path) unless $LOAD_PATH.include?(carbon_path)
require 'carbon'

Dir.glob(File.expand_path(File.dirname(__FILE__) + '/lib/**/*_examples.rb')).each do |file|
  require file
end

Dir.glob(File.expand_path(File.dirname(__FILE__) + '/support/**/*.rb')).each do |file|
  require file
end

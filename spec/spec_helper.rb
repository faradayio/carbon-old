require 'rubygems'
require 'bundler'
Bundler.setup
require 'rspec'
require 'ruby-debug'
require 'active_support/json/encoding'
require 'fakeweb'
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'carbon'

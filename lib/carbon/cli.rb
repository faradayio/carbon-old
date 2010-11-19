module Carbon
  module Cli
    def execute(*)
      Shell.init
      $emitters = {}
      IRB.start_session(Shell.new.get_binding)
    end 
    module_function :execute
  end
end

require 'carbon/cli/environment'
require 'carbon/cli/shell'
require 'carbon/cli/emitter'
require 'carbon/cli/irb'
require 'conversions'

if File.exist?(dotfile = File.join(ENV['HOME'], '.carbon_middleware'))
  if (key = IO.read(dotfile).strip).present?
    ::Carbon.key = key
  end
end

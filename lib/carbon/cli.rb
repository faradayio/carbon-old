module Carbon
  module Cli
    def execute(*)
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


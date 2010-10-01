require 'irb'
require 'pp'

module IRB # :nodoc:
  def self.start_session(binding)
    unless @__initialized
      args = ARGV
      ARGV.replace(ARGV.dup)
      IRB.setup(nil)
      ARGV.replace(args)
      @__initialized = true
    end

    workspace = WorkSpace.new(binding)

    @CONF[:PROMPT][:CARBON] = {
      :PROMPT_I => "%m> ",
      :PROMPT_S => "%m\"> ",
      :PROMPT_C => "%m…>",
      :PROMPT_N => "%m→>",
      :RETURN => ''
    }
    @CONF[:PROMPT_MODE] = :CARBON

    irb = Irb.new(workspace)

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context
    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end

module Carbon
  class Cli
    def self.execute(*)
      $emitters = {}
      IRB.start_session(Shell.new.get_binding)
    end      
    
    class Environment
      instance_methods.each do |m|
        undef_method(m) if m.to_s !~ /(?:^__|^nil\?$|^send$|^instance_eval$|^class$|^object_id$)/
      end

      def get_binding() binding end
      
      def method_missing(*args)
        return if [:extend].include? args.first
        puts "Unknown command #{args.first}"
      end
    end
    
    class Shell < Environment
      def help
        puts "  => FIXME A list of emitters should go here"
      end
      
      def to_s
        'carbon-'
      end
      
      def key(k)
        @key = k
        puts "  => Using key #{k}"
      end
      
      def flight(num = nil)
        if num and saved = $emitters[:flight][num]
          IRB.start_session(saved.get_binding)
        else
          emitter :flight
        end
      end
      
      def emitter(e)
        IRB.start_session(Emitter.new(e, @key).get_binding)
      end
    end
    
    class Emitter < Environment
      include Carbon
      def initialize(name, key)
        @emitter = name
        @input = {}
        @key = key
        characteristics_url = "http://carbon.brighterplanet.com/#{@emitter.to_s.pluralize}/options.json"
        response = REST.get(characteristics_url)
        if response.ok?
          @characteristics = JSON.parse(response.body)
          @characteristics.keys.each do |characteristic|
            instance_eval <<-meth
              def #{characteristic}(arg = nil)
                if arg
                  @input[:#{characteristic}] = arg
                  emission
                else
                  @input[:#{characteristic}]
                end
              end
            meth
          end
          provisions = @characteristics.keys.map { |k| "provide :#{k}"}.join('; ')
          emit_as_block = "emit_as(:#{name}) { #{provisions} }"
          self.class.class_eval emit_as_block
          emission
        else
          puts "  => Sorry, characteristics couldn't be retrieved for #{@emitter.to_s.pluralize} (via #{url})"
          done
        end
      end
      
      def emission
        puts "  => #{::Carbon::EmissionEstimate.new(self).to_f}"
      end
      
      def characteristics
        if @input.empty?
          puts "  => (none)"
        else
          first = true
          @input.each_pair do |key, value|
            if first
              puts "  => #{key}: #{value}"
              first = false
            else
              puts "     #{key}: #{value}"
            end
          end
        end
      end
      
      def url
        request = ::Carbon::EmissionEstimate.new(self).request
        url = request.url
        if request.body.present?
          url << '?'
          url << request.body
        end
        puts "  => #{url}"
      end
      
      def methodology
        first = true
        ::Carbon::EmissionEstimate.new(self).reports.each do |report|
          if first
            w = '  => '
            first = false
          else
            w = '     '
          end
          puts w + "#{report['committee']['name']}: #{report['quorum']['name']}"
        end
      end
      
      def reports
        first = true
        ::Carbon::EmissionEstimate.new(self).reports.each do |report|
          if first
            w = '  => '
            first = false
          else
            w = '     '
          end
          puts w + "#{report['committee']['name']}: #{report['conclusion'].inspect}"
        end
      end
      
      def help
        puts "  => #{@characteristics.keys.join ', '}"
      end
      
      def to_s
        "#{@emitter}*"
      end
      
      def done
        $emitters[@emitter] ||= []
        $emitters[@emitter] << self
        puts "  => Saved as #{@emitter} ##{$emitters[@emitter].length - 1}"
        throw :IRB_EXIT
      end
    end
  end
end

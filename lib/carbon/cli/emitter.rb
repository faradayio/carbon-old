module Carbon
  module Cli
    class Emitter < Environment
      include Carbon
      def initialize(name, key, input = {})
        @emitter = name
        @input = input
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
          if self.class.carbon_base && self.class.carbon_base.translation_table.any?
            self.class.carbon_base.reset_translation_table!
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
        puts "  => #{::Carbon::EmissionEstimate.new(self).to_f} kg CO2e"
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
      
      def inspect
        "<Emitter[#{@emitter}]: #{@input.inspect}>"
      end
      
      def done
        $emitters[@emitter] ||= []
        $emitters[@emitter] << @input
        puts "  => Saved as #{@emitter} ##{$emitters[@emitter].length - 1}"
        throw :IRB_EXIT
      end
    end
  end
end

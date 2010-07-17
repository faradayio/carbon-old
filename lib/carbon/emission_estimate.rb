module Carbon
  # Let's start off by saying that <tt>EmissionEstimate</tt> objects quack like numbers.
  #
  # So, you can just say <tt>puts my_car.emission</tt> and you'll get something like <tt>4308.29</tt>.
  #
  # At the same time, they contain all the data you get back from the emission estimate web service. For example, you could say <tt>puts my_donut_factor.emission.oven_count</tt> (see the tests) and you'd get back the oven count used in the calculation, if any.
  class EmissionEstimate
    attr_reader :data
    def initialize(data)
      @data = data
      @number = data['emission'].to_f.freeze
    end
    def ==(other) #:nodoc:
      other == @number
    end
    # Another way to access the emission value.
    # Useful if you don't like treating <tt>EmissionEstimate</tt> objects like <tt>Numeric</tt> objects (even though they do quack like numbers...)
    def emission_value
      @number
    end
    # The units of the emission.
    def emission_units
      data['emission_units']
    end
    # The Timeframe the emission estimate covers.
    #   > my_car.emission.timeframe.to_param
    #   => '2009-01-01/2010-01-01'
    def timeframe
      Timeframe.interval data['timeframe']
    end
    # Errors (and warnings) as reported in the response.
    # Note: may contain HTML tags like KBD or A
    def errors
      data['errors']
    end
    # The URL of the methodology report indicating how this estimate was calculated.
    #   > my_car.emission.methodology
    #   => 'http://carbon.brighterplanet.com/automobiles.html?[...]'
    def methodology
      data['methodology']
    end
    # You can ask an EmissionEstimate object for any of the response data provided.
    # This is useful for characteristics that are unique to an emitter.
    #
    # For example:
    #   > my_car.emission.model
    #   => 'Ford Taurus'
    #
    # sabshere 7/17/10
    #
    # http://stackoverflow.com/questions/1095789/sub-classing-fixnum-in-ruby
    #
    # note that we are not following wycat's revision http://stackoverflow.com/posts/1095993/revisions
    #
    # if this is treated like a number, we don't want to respond with an EmissionEstimate
    #
    def method_missing(method_id, *args, &blk)
      if !block_given? and args.empty? and data.has_key? method_id.to_s
        data[method_id.to_s]
      else
        @number.send method_id, *args, &blk
      end
    end
  end
end

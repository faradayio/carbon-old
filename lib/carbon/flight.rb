module Carbon
  class Flight
    include Carbon::Emitter

    characteristics :date, :year, :time_of_day, :destination_airport, 
      :origin_airport, :distance_class, :distance_estimate, :domesticity, 
      :airline, :trips, :emplanements_per_trip, :seat_class, :load_factor, 
      :seats_estimate, :aircraft_class, :aircraft, :propulsion
  end
end

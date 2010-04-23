require 'spec_helper'

describe Carbon::Flight do
  let(:emitter) { Carbon::Flight.new }
  it_should_behave_like Carbon::Emitter.to_s
end

describe 'Carbon::Flight integration' do
  before(:all) do
    FakeWeb.register_uri :post, 'http://carbon.brighterplanet.com/flights',
      :body => <<JSON
{"seat_class_multiplier":1.0,"load_factor":0.777639993987643,"emission":1201.517960422,"fuel_type":{"name":"Jet fuel","radiative_forcing_index":2.0,"emission_factor":2.52713934355099,"density":3.057},"emission_factor":3.1292977073347,"adjusted_distance_per_segment":834.614012327246,"radiative_forcing_index":2.0,"adjusted_distance":1393.8054005865,"trips":1.941,"distance":1121.73083058674,"fuel_use_coefficients":{"m1":6.61504931671615,"m2":-0.000207195999880949,"m3":1.18181254213862e-07},"freight_share":0.0237911536774234,"emplanements_per_trip":1.67,"endpoint_fuel":1470.9029045756,"fuel":22418.9620554941,"methodology":"http://carbon.brighterplanet.com/flights.html","date":"2010-01-01","passengers":114,"seats":146.032431554052,"fuel_per_segment":6916.29478461751}
JSON
  end

  it 'should fetch emission data' do
    flight = Carbon::Flight.new
    flight.calculate!
    flight.emission.should be_close(1201.5, 0.1)
  end
end

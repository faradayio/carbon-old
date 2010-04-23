require 'rest_client'

shared_examples_for Carbon::Resource.to_s do
  it { should be_a_kind_of(Carbon::Resource) }
end

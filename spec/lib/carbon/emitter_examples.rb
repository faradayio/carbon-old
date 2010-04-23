shared_examples_for Carbon::Emitter.to_s do
  it { should be_a_kind_of(Carbon::Emitter) }

  let(:resource_object) { emitter }
  it_should_behave_like Carbon::Resource.to_s

  it { should respond_to(:emission) }
  it { should respond_to(:methodology) }
end

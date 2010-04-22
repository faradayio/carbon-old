shared_examples_for Carbon::Emitter.to_s do
  it { should be_a_kind_of(Carbon::Emitter) }
  it { should respond_to(:footprint) }

  describe '#calculate!' do
    it 'should calculate a footprint'
  end

  describe '#methodology_url' do
    it 'should raise an error if no calculation has been performed' do
      expect { emitter.methodology_url }.to raise_error(Carbon::Emitter::NotYetCalculated)
    end
    it 'should return the url' do
      emitter.calculate!
      emitter.methodology_url.should =~ /http:\/\//
    end
  end
end

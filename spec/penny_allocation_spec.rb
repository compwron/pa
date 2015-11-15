require_relative '../lib/penny_allocation'

describe PennyAllocation do

  class Foo
    include PennyAllocation
  end

  subject { Foo.new.reallocate_partial_pennies(array_of_values, options) }

  context 'with empty parameters' do
    let(:array_of_values) {[]}
    let(:options) {{}}
    it 'returns empty array' do
      expect(subject).to eq []
    end
  end
end

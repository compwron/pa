require_relative 'spec_helper'

describe PennyAllocation do
  let(:a) { 'UNKNOWN EXPECTATION' }

  class PennyAllocator
    include PennyAllocation
  end

  subject { PennyAllocator.new.reallocate_partial_pennies(array_of_values, options) }

  context 'with empty parameters' do
    let(:array_of_values) {[]}
    let(:options) {{}}
    it 'returns empty array' do
      expect(subject).to eq []
    end
  end

  context 'with invalid array_of_values' do
    let(:array_of_values) { ['invalid'] }
    let(:options) {{}}
    it 'raises exception' do
      expect{subject}.to raise_exception NoMethodError
    end
  end

  context 'with array_of_values' do
    let(:options) {{}}

    context 'with single value 0' do
      let(:array_of_values) {[0]}
      it 'returns same' do
        expect(subject).to eq [0]
      end
    end

    context 'with ordered list' do
      let(:array_of_values) {[0, 99, 2, 4, 88]}
      it 'keeps the order' do
        expect(subject).to eq array_of_values
      end
    end

    context 'with small fractional penny' do
      let(:array_of_values) {[4.1]}
      it 'drops the penny' do
        expect(subject).to eq [4]
      end
    end

    context 'with half a penny' do
      let(:array_of_values) {[1.5]}
      it 'rounds up' do
        expect(subject).to eq [2]
      end
    end

    context 'with partial pennies' do
      let(:array_of_values) {[ 1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0]}
      it 'rounds' do
        expect(subject).to eq [1, 2, 3, 4, 6, 7, 8, 9, 10, 10]
      end
    end

    context 'with enough low partials to make two wholes' do
      let(:array_of_values) {[0.2] * 8}
      it 'rounds to having two wholes' do
        expect(subject).to eq [1, 1, 0, 0, 0, 0, 0, 0]
      end
    end

    context 'with not enough low partials to make two wholes' do
      let(:array_of_values) {[0.2] * 7}
      it 'rounds to only one whole' do
        expect(subject).to eq [1, 0, 0, 0, 0, 0, 0]
      end
    end

    context 'with negatives, which should never happen' do
      context 'with negative at the beginning' do
        let(:array_of_values) { [-1, 0.4, 0.4, 0.4]}
        it 'reverses where the additive whole sits' do
          # I don't know why this happens or whether it is desired behavior
          expect(subject).to eq  [-1, 0, 0, 1]
        end
      end

      context 'with negative second' do
        let(:array_of_values) {[0.4, -1, 0.4, 0.4]}
        it 'rounds' do
          expect(subject).to eq [1, -1, 0, 0]
        end
      end
    end
  end

  context 'with options' do
    context 'with values' do
      let(:array_of_values) {[0]}
      context 'with invalid options' do
        let(:options) { 'invalid options' }
        it 'raises NameError' do
          expect{subject}.to raise_exception TypeError
        end
      end
    end

    context 'without values' do
      let(:array_of_values) {[]}
      context 'with invalid comp total' do
        let(:options) { {comp_total: 'invalid'}}
        it 'raises NameError' do
          expect(subject).to eq []
        end
      end

      context 'with leftover total adding up to half' do
        let(:array_of_values) {[0.25, 0.25]}
        context 'with comp_total' do
          let(:options) {{comp_total: true}}
          it 'rounds down both values' do
            expect(subject).to eq [0, 0]
          end
        end

        context 'without comp_total' do
          let(:options) {{comp_total: false}}
          context 'with quarters' do
            it 'preserves the half cent' do
              expect(subject).to eq [1, 0]
            end
          end

          context 'with thirds' do
            let(:array_of_values) {[0.3, 0.3, 0.3]}
            it 'rounds one of them up and the rest of them down' do
              expect(subject).to eq [1, 0, 0]
            end
          end
        end
      end
    end
  end

  context '#round_comp_total' do
    context 'with extra' do
      let(:numbers) {{
          0.51 => 1,
          0.501 => 1,
          0.5001 => 1,
          0.50001 => 1,
          0.500001 => 1,
          0.5 => 0,
          0.4 => 0}}
      it 'rounds up for just above .5' do
        numbers.each do |number, result|
          expect(PennyAllocator.new.round_comp_total(number)).to eq result
        end
      end
    end
  end
end

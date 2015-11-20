require_relative 'spec_helper'

class PennyAllocator
  include PennyAllocation
end

describe PennyAllocator do
  subject { PennyAllocator.new }
  it "should pass the values back in the same order" do
    expect(subject.reallocate_partial_pennies([ 4, 5, 3, 1, 2 ])).
      to eq([ 4, 5, 3, 1, 2 ])
  end

  it "drops a small fractional penny" do
    expect(subject.reallocate_partial_pennies([ 4.1, 1])).to eq([ 4, 1 ])
  end

  it "adds more than half a penny to the number closest to the next integer" do
    expect(subject.reallocate_partial_pennies([ 4.1, 1.5 ])).to eq([ 4, 2 ])
  end

  it "adds pennies in the order of closeness to next integer" do
    expect(subject.reallocate_partial_pennies([ 1.1, 3.3, 4.4, 5.5, 6.6, 7.7])).
      to eq([1, 3, 4, 6, 7, 8])
  end

  it "rounds one number" do
    expect(subject.reallocate_partial_pennies([1.9])).to eq([2])
  end

  it "round down 0.5 for comp_total" do
    expect(subject.reallocate_partial_pennies([5.25,5.25], comp_total: true)).to eq([5, 5])
  end

  it "round up 0.5 for non comp_total" do
    expect(subject.reallocate_partial_pennies([5.25,5.25])).to eq([6, 5])
  end

  describe "#special_round" do
    it "rounds down 4.500" do
      expect(subject.round_comp_total(4.500)).to eq(4)
    end

    it "rounds up 4.5001" do
      expect(subject.round_comp_total(4.5001)).to eq(5)
    end
  end

  context 'new tests for rewrite' do
    subject { PennyAllocator.new.reallocate_partial_pennies(array_of_values, options) }

    context 'with empty parameters' do
      let(:array_of_values) { [] }
      let(:options) { {} }
      it 'returns empty array' do
        expect(subject).to eq []
      end
    end

    context 'with invalid array_of_values' do
      let(:array_of_values) { ['invalid'] }
      let(:options) { {} }
      it 'raises exception' do
        expect { subject }.to raise_exception NoMethodError
      end
    end

    context 'with array_of_values' do
      let(:options) { {} }

      context 'with single value 0' do
        let(:array_of_values) { [0] }
        it 'returns same' do
          expect(subject).to eq [0]
        end
      end

      context 'with ordered list' do
        let(:array_of_values) { [0, 99, 2, 4, 88] }
        it 'keeps the order' do
          expect(subject).to eq array_of_values
        end
      end

      context 'with small fractional penny' do
        let(:array_of_values) { [4.1] }
        it 'drops the penny' do
          expect(subject).to eq [4]
        end
      end

      context 'with half a penny' do
        let(:array_of_values) { [1.5] }
        it 'rounds up' do
          expect(subject).to eq [2]
        end
      end

      context 'with partial pennies' do
        let(:array_of_values) { [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0] }
        it 'rounds' do
          expect(subject).to eq [1, 2, 3, 4, 6, 7, 8, 9, 10, 10]
        end
      end

      context 'with enough low partials to make two wholes' do
        let(:array_of_values) { [0.2] * 8 }
        it 'rounds to having two wholes' do
          expect(subject).to eq [1, 1, 0, 0, 0, 0, 0, 0]
        end
      end

      context 'with not enough low partials to make two wholes' do
        let(:array_of_values) { [0.2] * 7 }
        it 'rounds to only one whole' do
          expect(subject).to eq [1, 0, 0, 0, 0, 0, 0]
        end
      end

      context 'with values and invalid non-false comp total' do
        let(:array_of_values) { [0.5] }
        let(:options) { {comp_total: 'invalid'} }
        it 'returns empty array' do
          expect(subject).to eq [0]
        end
      end

      context 'with values and valid comp total' do
        let(:array_of_values) { [0.5] }
        let(:options) { {comp_total: false } }
        it 'returns empty array' do
          expect(subject).to eq [1]
        end
      end
    end

    context 'with options' do
      context 'with values' do
        let(:array_of_values) { [0] }
        context 'with invalid options' do
          let(:options) { 'invalid options' }
          it 'raises TypeError' do
            expect { subject }.to raise_exception TypeError
          end
        end
      end

      context 'without values' do
        let(:array_of_values) { [] }
        context 'with invalid comp total' do
          let(:options) { {comp_total: 'invalid'} }
          it 'returns empty array' do
            expect(subject).to eq []
          end
        end

        context 'with leftover total adding up to half' do
          let(:array_of_values) { [0.25, 0.25] }
          context 'with comp_total' do
            let(:options) { {comp_total: true} }
            it 'rounds down both values' do
              expect(subject).to eq [0, 0]
            end
          end

          context 'without comp_total' do
            let(:options) { {comp_total: false} }
            context 'with quarters' do
              it 'preserves the half cent' do
                expect(subject).to eq [1, 0]
              end
            end

            context 'with thirds' do
              let(:array_of_values) { [0.3, 0.3, 0.3, 0.3] }
              it 'rounds one of them up and the rest of them down' do
                expect(subject).to eq [1, 0, 0, 0]
              end
            end
          end
        end
      end
    end

    context '#round_comp_total' do
      context 'with extra' do
        let(:numbers) { {
            0.51 => 1,
            0.501 => 1,
            0.5001 => 1,
            0.50001 => 1,
            0.500001 => 1,
            0.5 => 0,
            0.4 => 0} }
        it 'rounds up for just above .5' do
          numbers.each do |number, result|
            expect(PennyAllocator.new.round_comp_total(number)).to eq result
          end
        end
      end
    end
  end
end

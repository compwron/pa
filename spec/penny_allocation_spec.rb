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
  end

  context 'with options' do
    let(:array_of_values) {[]}

    context 'with invalid options' do
      let(:options) { 'invalid options' }
      it 'raises NameError' do
        expect{subject}.to raise_exception TypeError
      end
    end

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
        it 'preserves the half cent' do
          expect(subject).to eq [1, 0]
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
          0.500001 => 1}}
      it 'rounds up for just above .5' do
        numbers.each do |number, result|
          expect(PennyAllocator.new.round_comp_total(number)).to eq result
        end
      end
    end
  end
end

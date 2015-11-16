require 'pry'
module PennyAllocation
  def reallocate_partial_pennies(array_of_values, options = {})

    aoh = floored_values_with_fractional_remainders(array_of_values)

    values = aoh.sort_by do |hash|
      1 - hash[:fractional_value]
    end

    values.each_with_index do |hash, index|
      hash[:value] += 1 if index < number_to_allocate(options, fractional_sum(aoh))
    end

    aoh.map {|h| h[:value] }
  end

  def round_comp_total(number)
    if number % 1 == 0.500000
      number.floor
    else
      number.round
    end
  end

  private

  def fractional_sum(aoh)
    sum = 0
    aoh.each do |hash|
      sum += hash[:fractional_value]
    end
    sum
  end

  def floored_values_with_fractional_remainders(values)
    values.each_with_index.map do |v, index|
      {fractional_value: (v % 1), value: v.floor, index: index}
    end
  end

  def number_to_allocate(options, fractional_sum)
    if options[:comp_total]
        round_comp_total(fractional_sum)
      else
        fractional_sum.round
      end
    end
end

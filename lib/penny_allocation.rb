require 'pry'
module PennyAllocation
  def reallocate_partial_pennies(array_of_values, options = {})
    fractional_sum = 0

    aoh = floored_values_with_fractional_remainders(array_of_values)

    values = aoh.sort_by do |hash|
      fractional_sum += hash[:fractional_value]
      1 - hash[:fractional_value]
    end

    values.each_with_index do |hash, index|
      hash[:value] += 1 if index < number_to_allocate(options, fractional_sum)
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

  def floored_values_with_fractional_remainders(values)
    values.map do |v|
      {fractional_value: (v % 1), value: v.floor}
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

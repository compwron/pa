require 'pry'
module PennyAllocation
  def reallocate_partial_pennies(array_of_values, options = {})
    fractional_sum = 0

    array_of_hashes = array_of_values.map {|v| { value: v }}

    values = array_of_hashes.sort_by do |hash|
      fractional_value = hash[:value] % 1
      hash[:value] = hash[:value].floor
      fractional_sum += fractional_value
      1 - fractional_value
    end

    values.each_with_index do |hash, index|
      hash[:value] += 1 if index < number_to_allocate(options, fractional_sum)
    end

    array_of_hashes.map {|h| h[:value] }
  end

  def round_comp_total(number)
    if number % 1 == 0.500000
      number.floor
    else
      number.round
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

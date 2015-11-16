require 'pry'
module PennyAllocation
  def reallocate_partial_pennies(array_of_values, options = {})
    floored_values_with_fractional_remainders(array_of_values).sort_by do |hash|
      1 - hash[:fractional_value]
    end.each_with_index do |hash, index|
      if index_less_than_number_to_allocate(index, options, array_of_values)
        hash[:value] += 1
      end
    end.sort_by do |hash|
      hash[:index]
    end.map do |hash|
      hash[:value]
    end
  end

  def round_comp_total(number)
    if number % 1 == 0.500000
      number.floor
    else
      number.round
    end
  end

  private

  def index_less_than_number_to_allocate(index, options, array_of_values)
    index < number_to_allocate(options, fractional_sum(array_of_values))
  end

  def fractional_sum(values)
    values.map do |val|
      fractional_value(val)
    end.inject(&:+)
  end

  def floored_values_with_fractional_remainders(values)
    values.each_with_index.map do |v, index|
      {fractional_value: fractional_value(v), value: v.floor, index: index}
    end
  end

  def fractional_value(value)
    value % 1
  end

  def number_to_allocate(options, fractional_sum)
    if options[:comp_total]
        round_comp_total(fractional_sum)
      else
        fractional_sum.round
      end
    end
end

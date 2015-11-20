module PennyAllocation
  require 'ostruct'

  # reallocate_partial_pennies takes two arguments: an array of values which is
  # a list of values in pennies, where values can include ddractions of a penny.
  # For example, [2.5, 5.1] which contains, two and a half pennies, and also five and a tenth pennies.
  # We do not expect negative values in this array.
  # the second argument is 'options' which contains an optional value for :comp total
  # If options[:comp_total] is present and not false, we round values differently.
  def reallocate_partial_pennies(array_of_values, options = {})
    unsorted_values = enhanced_values(array_of_values)
    sorted_values = sort_by_fractional(unsorted_values)

    (0...pennies_to_allocate(sorted_values, options)).each do |i|
      sorted_values[i].whole += 1
    end

    unsorted_values.map(&:whole)
  end

  # round the total fractional pennies
  # if options[:comp_total] is set, 0.5 is rounded downwards.
  def round_comp_total(total)
    if total % 1 == 0.5
      total.floor
    else
      total.round
    end
  end

  private

  def pennies_to_allocate(values, options)
    # round off the sum, since we can't end with a fraction of a penny
    sum = values.inject(0) {|sum, v| sum + v.fractional}
    rounded_partial_pennies_sum(options, sum)
  end

  def enhanced_values(values)
    # split into whole and fractional parts.
    # preserve the original position of each value, since we will be sorting
    # the array and need to unsort at the end.
    values.map do |v|
      OpenStruct.new.tap do |val|
        val.whole, val.fractional = v.divmod 1
      end
    end
  end

  def sort_by_fractional(values)
    values.sort_by {|v| -v.fractional}
  end

  def rounded_partial_pennies_sum(options, partial_pennies_sum)
    if options[:comp_total]
      round_comp_total(partial_pennies_sum)
    else
      partial_pennies_sum.round
    end
  end
end

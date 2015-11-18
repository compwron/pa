module PennyAllocation
  require 'ostruct'
  def reallocate_partial_pennies(array_of_values, options = {}) # public method
    values = enhanced_values(array_of_values)

    (0...rounded_partial_pennies_sum(options, partial_pennies_sum(values))).each do |i|
      values[i].whole += 1
    end

    # restore the original order and return the adjusted whole penny values
    values.sort_by(&:index).map(&:whole)
  end

  # round the total fractional pennies
  # if options[:comp_total] is set, 0.5 is rounded downwards.
  def round_comp_total(total) # pubic method
    if total % 1 == 0.5
      total.floor
    else
      total.round
    end
  end

  private

  def partial_pennies_sum(values)
    # round off the sum, since we can't end with a fraction of a penny
    values.inject(0) {|sum, v| sum + v.fractional}
  end

  def enhanced_values(values)
    # split into whole and fractional parts.
    # preserve the original position of each value, since we will be sorting
    # the array and need to unsort at the end.
    values.each_with_index.map do |v, i|
      OpenStruct.new.tap do |val|
        val.whole, val.fractional = v.divmod 1
        val.index = i
      end
    end.sort_by {|v| -v.fractional}
  end

  def rounded_partial_pennies_sum(options, partial_pennies_sum)
    if options[:comp_total]
      round_comp_total(partial_pennies_sum)
    else
      partial_pennies_sum.round
    end
  end
end

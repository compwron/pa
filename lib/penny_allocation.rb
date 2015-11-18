require 'ostruct'

module PennyAllocation
  def reallocate_partial_pennies(array_of_values, options = {})
    # split into whole and fractional parts.
    # preserve the original position of each value, since we will be sorting
    # the array and need to unsort at the end.
    values = array_of_values.each_with_index.map do |v, i|
      OpenStruct.new.tap do |val|
        val.whole, val.fractional = v.divmod 1
        val.index = i
      end
    end

    # round off the sum, since we can't end with a fraction of a penny
    partial_pennies = values.inject(0) {|sum, v| sum + v.fractional}
    partial_pennies = round_total(options, partial_pennies)

    # round down the values, and redistribute the total partial_pennies among
    # them in decreasing order of their original fractional pennies
    values = values.sort_by {|v| -v.fractional}
    (0 ... partial_pennies).each do |i|
      values[i].whole += 1
    end

    # restore the original order and return the adjusted whole penny values
    values.sort_by(&:index).map(&:whole)
  end

  # round the total fractional pennies
  # if options[:comp_total] is set, 0.5 is rounded downwards.
  def round_total(options, total)
    if options[:comp_total] and total % 1 == 0.5
      total.floor
    else
      total.round
    end
  end
end

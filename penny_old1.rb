module Olap
  class PennyAllocator
    attr_accessor :amount, :values

    def initialize(amount, values)
      self.amount = amount
      self.values = values
    end

    def allocate
      pennies = amount - distributed_amounts.map(&:floor).sum
      fractional_pennies = distributed_amounts.map {|a| a.to_f - a.to_i }
      sorted_fractional_pennies = fractional_pennies.sort.reverse[0, pennies]

      amounts = distributed_amounts.zip(fractional_pennies).map do |a, v|
        if pennies > 0 && sorted_fractional_pennies.include?(v)
          pennies -= 1
          a + 1
        else
          a
        end
      end

      amounts.map(&:to_i)
    end

    private

    def total
      @total ||= values.sum
    end

    def value_ratios
      @value_ratios ||= values.map {|v| total > 0 ? v.to_f / total : 0 }
    end

    def distributed_amounts
      @distributed_amounts ||= value_ratios.map {|v| v * amount }
    end

  end
end

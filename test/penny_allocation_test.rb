require 'minitest/autorun'
require_relative '../lib/penny_allocation'

class PennyAllocationTest < Minitest::Test
  include PennyAllocation

  def check(before, after)
    assert_equal after, reallocate_partial_pennies(before)
  end

  def test_empty
    check [], []
  end

  def test_all_whole
    check [3, 1, 4, 1, 5], [3, 1, 4, 1, 5]
  end

  def test_single_fractional_discard
    check [1, 2, 3.4], [1, 2 ,3]
  end

  def test_single_fractional_keep
    check [4, 2.6, 3], [4, 3 ,3]
  end

  def test_multiple_fractional
    check [1.8, 6.5, 3.2, 8.6], [2, 6, 3, 9]
  end

  def test_half_penny_keep
    check [1, 2.5, 3], [1, 3, 3]
  end

  def test_half_penny_discard
    assert_equal [1, 2, 3],
      reallocate_partial_pennies([1, 2.5, 3], comp_total: true)
  end
end

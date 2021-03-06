require 'test_helper'

class OrderableTest < ActiveSupport::TestCase
  def test_returns_an_empty_hash_when_not_valid
    orderable = Orderable.new('some_model', 'some_column', 'desc')

    assert_equal('', orderable.condition)
  end

  def test_returns_the_default_when_not_valid_and_default_given
    orderable = Orderable.new('some_model', 'some_column', 'desc', {id: :desc})

    assert_equal({id: :desc}, orderable.condition)
  end

  def test_returns_order_hash_for_valid_conditions
    orderable = Orderable.new('Auction', 'domain_name', 'desc', {id: :desc})

    assert_equal('auctions.domain_name desc', orderable.condition)
  end

  def test_order_hashes_are_chainable_in_a_query
    orderable = Orderable.new('Auction', 'domain_name', 'desc', {id: :desc})
    second_orderable = Orderable.new('Auction', 'uuid', 'desc')

    assert_nothing_raised do
      result = Auction.order(orderable.condition).order(second_orderable.condition)
      assert(result.is_a?(ActiveRecord::Relation))
    end
  end
end

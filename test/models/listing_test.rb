require "test_helper"

class ListingTest < ActiveSupport::TestCase
  def setup
    @listing = listings(:listing_one)
  end

  test "Requires valid currency" do
    @listing.currency = "INVALID"

    assert_not @listing.valid?
    assert_includes @listing.errors[:currency], "INVALID is not a valid currency"
  end

  test "Allows nil currency" do
    @listing.currency = nil

    assert @listing.valid?
  end

  test "Condition must be valid enum value" do
    assert_raises ArgumentError do
      @listing.condition = "fake_condition"
    end
  end

  test "Price must be non-negative" do
    @listing.price = -5

    assert_not @listing.valid?
    assert_includes @listing.errors[:price], "must be greater than or equal to 0"
  end

  test "Condition helpers work" do
    listing = listings(:listing_two)

    assert listing.used_condition?
    assert_equal "Tweedehands", listing.condition_label
  end

  test "Condition labels" do
    assert_equal "Nieuw", listings(:listing_one).condition_label
    assert_equal "Tweedehands", listings(:listing_two).condition_label

    damaged = Listing.new(book: books(:book_one), source: sources(:source_one), condition: :damaged, currency: "EUR", price: 5.0)
    assert_equal "Licht beschadigd", damaged.condition_label

    unknown = Listing.new(book: books(:book_one), source: sources(:source_one), condition: :unknown, currency: "EUR", price: 5.0)
    assert_equal "Onbekend", unknown.condition_label
  end

  test "Price parts are extracted correctly" do
    @listing.price = 29.95
    assert_equal "29", @listing.price_large
    assert_equal "95", @listing.price_cents

    @listing.price = 10.5
    assert_equal "10", @listing.price_large
    assert_equal "50", @listing.price_cents
  end

  test "Price label is formatted correctly" do
    @listing.price = 12.34
    assert_equal "€12,34", @listing.price_label
  end

  test "Shipping cost is free when price_includes_shipping" do
    listing = listings(:listing_two)

    assert_equal 0, listing.shipping_cost_actual
    assert_equal "Gratis verzending", listing.shipping_label
  end

  test "Shipping cost is free when above source free threshold" do
    source = sources(:source_one)
    source.update!(shipping_cost_free_from_price: 20)

    listing = listings(:listing_one)

    assert_equal 0, listing.shipping_cost_actual
    assert_equal "Gratis verzending", listing.shipping_label
  end

  test "Shipping cost applies when under threshold" do
    source = sources(:source_one)
    source.update!(shipping_cost: 4.99, shipping_cost_free_from_price: 50)

    listing = listings(:listing_one) # price: 29.99
    assert_equal 4.99, listing.shipping_cost_actual
    assert_equal "+€4,99 verzenden", listing.shipping_label
  end

  test "After save updates book cache" do
    book = @listing.book
    @listing.update!(price: 25.00)

    assert_equal book.lowest_price, book.reload.listings_lowest_price_cache
    assert_equal book.listings_with_price.size, book.reload.listings_available_count_cache
  end

  test "After destroy updates book cache" do
    book = @listing.book
    @listing.destroy

    assert_nil book.reload.listings_lowest_price_cache
    assert_equal book.listings_with_price.size, book.reload.listings_available_count_cache
  end
end

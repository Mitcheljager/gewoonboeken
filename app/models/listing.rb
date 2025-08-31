class Listing < ApplicationRecord
  has_paper_trail only: [:price]

  belongs_to :book
  belongs_to :source

  enum :condition, [:unknown, :new, :used, :damaged], suffix: true

  validates :currency, inclusion: { in: VALID_CURRENCIES, message: "%{value} is not a valid currency" }, allow_nil: true
  validates :condition, inclusion: { in: Listing.conditions.keys }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_save :update_book_cache
  after_destroy :update_book_cache

  def price_large
    price.to_s.split(".")[0]
  end

  def price_cents
    cents = price.to_s.split(".")[1]

    return cents + "0" if cents.size == 1
    cents
  end

  def price_label
    "€#{price_large},#{price_cents}"
  end

  def shipping_cost_actual
    # If the listing price includes shipping or if the price includes the sources free shipping cost threshold
    return 0 if price_includes_shipping? || (source.shipping_cost_free_from_price > 0 && price >= source.shipping_cost_free_from_price)
    source.shipping_cost
  end

  def shipping_label
    return "Gratis verzending" if shipping_cost_actual == 0
    "+€#{format("%.2f", shipping_cost_actual).gsub(".", ",")} verzenden"
  end

  def condition_label
    return "Nieuw" if new_condition?
    return "Tweedehands" if used_condition?
    return "Licht beschadigd" if damaged_condition?
    "Onbekend"
  end

  private

  def update_book_cache
    book.update!(listings_lowest_price_cache: book.lowest_price, listings_available_count_cache: book.listings_with_price.size)
    book.touch
  end
end

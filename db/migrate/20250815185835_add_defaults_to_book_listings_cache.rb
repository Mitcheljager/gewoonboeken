class AddDefaultsToBookListingsCache < ActiveRecord::Migration[8.0]
  def up
    change_column_default :books, :listings_lowest_price_cache, from: nil, to: 0.0
    change_column_default :books, :listings_available_count_cache, from: nil, to: 0

    Book.where(listings_lowest_price_cache: nil).update_all(listings_lowest_price_cache: 0.0)
    Book.where(listings_available_count_cache: nil).update_all(listings_available_count_cache: 0)
  end

  def down
    change_column_default :books, :listings_lowest_price_cache, from: 0.0, to: nil
    change_column_default :books, :listings_available_count_cache, from: 0, to: nil
  end
end

class AddListingsCacheToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :listings_lowest_price_cache, :float
    add_column :books, :listings_available_count_cache, :integer

    reversible do |direction|
      direction.up do
        execute <<~SQL
          UPDATE books
          SET listings_lowest_price_cache = sub.lowest_price,
              listings_available_count_cache = sub.listing_count
          FROM (
            SELECT book_id,
                   MIN(CASE
                       WHEN available = TRUE
                        AND price IS NOT NULL
                        AND price != 0
                       THEN price
                   END) AS lowest_price,
                   SUM(CASE
                       WHEN available = TRUE
                        AND price IS NOT NULL
                        AND price != 0
                       THEN 1 ELSE 0
                   END) AS listing_count
            FROM listings
            GROUP BY book_id
          ) AS sub
          WHERE books.id = sub.book_id
        SQL
      end
    end
  end
end

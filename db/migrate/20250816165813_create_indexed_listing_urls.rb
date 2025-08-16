class CreateIndexedListingUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :indexed_listing_urls do |t|
      t.string :source_name
      t.string :isbn
      t.string :url

      t.timestamps
    end
  end
end

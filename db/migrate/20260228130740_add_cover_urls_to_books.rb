class AddCoverUrlsToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :cover_url_large, :string
    add_column :books, :cover_url_small, :string
  end
end

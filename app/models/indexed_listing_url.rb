class IndexedListingUrl < ApplicationRecord
  # This model exists as a way to save URLs fetched from overview pages, such as when fetching popular books.
  # Some websites (boeken.nl) have URLs that are mostly consistent, but not always. For instance, they might
  # contain genres right in their URL, but only sometimes.
  # By saving all URLs as we fetch their overview page we can fall back to them, rather than having to search.

  validates :source_name, presence: true
  validates :isbn, presence: true, format: { with: /\A\d{13}\z/ }
  validates :url, presence: true
end

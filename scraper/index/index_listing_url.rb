def index_listing_url(source_name, isbn, url)
  puts "Indexing URL #{url} for #{source_name} (#{isbn})"

  indexedUrl = IndexedListingUrl.find_or_initialize_by(source_name:, isbn:)
  indexedUrl.update(url:)
end

def find_indexed_listing_url(source_name, isbn)
  IndexedListingUrl.find_by(source_name:, isbn:)&.url
end

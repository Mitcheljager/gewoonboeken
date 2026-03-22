require_relative "../get_document"

def scrape_bol_partners(isbn)
  # Intentionally find by Bol.com listing, rather than Bol.com Partners listing.
  # If the Bol.com url doesn't exist, neither will the Partners url.
  # This prevents us from having to search
  listing = find_listing_for_isbn_and_source_name(isbn, "Bol.com")

  # Replace /p/ in the url with /prijsoverzicht/, this gets us to the partners list
  url = listing&.url&.sub("/p/", "/prijsoverzicht/")

  puts url

  if url.blank?
    puts "Bol.com Partners had no matching URL for Bol.com listing"

    return { url: nil, available: false }
  end

  puts "Running url for Bol.com Partners"

  document = get_document(url)

  return { url: nil, available: false } if document.nil?

  item = document.at_css("[data-testid='offer-compare-item']")
  item = document.css("[data-testid='offer-compare-item']")[1] if item&.text&.include?("Bol")

  return { url:, available: false } if item.nil?

  price = item.at_css(".text-promo-text-high").text.tr(",", ".").strip
  price_includes_shipping = item.text.include?("inclusief verzendkosten")
  condition = item.text.include?("Tweedehands") ? :used : :new

  { url:, price:, condition:, available: true, price_includes_shipping: }
end

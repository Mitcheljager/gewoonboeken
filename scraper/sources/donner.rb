require_relative "../get_document"
require_relative "../index/index_listing_url"

def scrape_donner(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Donner")

  # The slug part of the url doesn't actually matter, all that matter is that it contains a - and ISBN.
  # It doesn't even redirect to the actual page, it will serve the page for the given url as long as it
  # contains the ISBN. Makes it nice and easy!
  url = listing&.url || find_indexed_listing_url("Donner", isbn) || "https://www.donner.nl/producten/-#{isbn}"

  puts "Running Donner for: " + url

  document = get_document(url)

  return { url: nil, available: false } if document.blank? || document.include?("Pagina niet gevonden")

  price = document.at_css(".product-price__price")&.text&.gsub("€", "")&.gsub(",", ".")&.strip
  description = document.at_css(".product-details__description")&.text&.strip
  number_of_pages_label = document.at_css(".product-specifications__item:contains('Pagina')")
  number_of_pages = number_of_pages_label&.text&.gsub("Pagina's", "")&.strip

  # Donner fetches it's availability data via an internal API request after entering the page. We can't get
  # to that. They do however include the availability in a json object. However... this object often contains
  # errors. Unescapted quotes, missing quoutes, you name it. We can't actually parse the json. So we just
  # look for a string inside of it. This is also why we're not using the same json above, which would
  # contain all the fields we'd need.
  # One downside is that they only mark books is InStock or SoldOut, even when a different status would be
  # relevant, such as back-orders or pre-orders. So Unfortunately it's all or nothing.
  json_element = document.at_css("script[type='application/ld+json']")
  available = json_element&.text&.include?("InStock")

  { url:, price:, description:, number_of_pages:, available:, condition: :new }
end

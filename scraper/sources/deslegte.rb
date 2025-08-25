require_relative "../get_document"

# TODO: De Slegte has different shipping costs depending on the order.
# Used, ramsj, study: 2.50 + 1 per book
# New:
#   0-10: 4.95,
#   10-20: 1.95,
#   20+: free.
# Easier might be to add a shipping override value in listings.

def scrape_deslegte(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "De Slegte")

  url = listing&.url

  if listing&.url&.present?
    puts "Running previously fetched url For De Slegte for: " + url

    document = get_document(url)
  else
    puts "Running new url for De Slegte"

    # De Slegte doesn't have nice enough urls to visit them directly via slug + isbn.
    # Instead, we search first and get first result
    base_url = "https://www.deslegte.com"
    document = get_document("#{base_url}/boeken/?q=#{isbn}")

    return { url: nil, available: false } if document.nil? || document&.text&.include?("0 uitgaven gevonden")

    link_element = document.at_css(".searchresult__item a")
    first_url = link_element&.attribute("href")&.value

    # Get document again for url that was fetched from search
    url = base_url + first_url
    document = get_document(url)
  end

  return { url: nil, available: false } if document.nil?

  description = document.at_css(".product__page-description-content")&.text&.strip
  number_of_pages = document.at_css("product__page-spec-item:contains('pagina') .right")&.text&.strip

  # The price is shown as a sentence "Tweedehands vanaf 10,00. Nieuwe vanaf 22.99". Often only one of the two is present.
  # Extra all numbers, replace their commas with a period and cast to a float.
  # Get the lowest of all numbers.
  price_label = document.at_css(".product__page-currentformat-starting-price")&.text
  prices = price_label&.scan(/\d+,\d+/)&.map { |p| p.gsub(',', '.').to_f }
  price = prices&.min

  condition = price_label&.include?("Tweedehands vanaf") ? :used : :new

  # Price is only shown via the above element if the item is available. It's empty otherwise.
  available = price.present?

  { url:, price:, description:, number_of_pages:, condition:, available: }
end

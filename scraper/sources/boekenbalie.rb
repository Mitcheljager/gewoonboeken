require_relative "../get_document"

def scrape_boekenbalie(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boekenbalie")

  slug = title.parameterize
  url = listing&.url || "https://boekenbalie.nl/#{slug}/#{isbn}"

  if listing&.url
    puts "Running previously fetched url Boekenbalie for: " + url
  else
    puts "Running new url for Boekenbalie for: " + url
  end

  document = get_document(url)

  return { url: nil, available: false } if document.nil? || document.text.include?("Pagina niet gevonden")

  description = document.at_css(".js-product-detail-description-text")&.text&.strip
  number_of_pages_label = document.at_css(".product-detail-properties-label:contains('Aantal pagina')")
  number_of_pages = number_of_pages_label&.next_element&.text&.strip
  available = !document.text.include?("Niet op voorraad")

  return { url:, available: false } if !available

  price = document.css(".product-detail-price span").last.text.strip.gsub(",", ".")

  { url:, price:, description:, number_of_pages:, condition: :used, available: available }
end

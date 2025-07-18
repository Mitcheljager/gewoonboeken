require_relative "../base"
require "nokogiri"

def scrape_voordeelboekenonline(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Voordeelboekenonline.nl")

  url = listing&.url || "https://www.voordeelboekenonline.nl/catalogsearch/result/?q=#{isbn}"

  if listing&.url
    puts "Running previously fetched url Voordeelboekenonline.nl for: " + url
  else
    puts "Running new url for Voordeelboekenonline.nl for: " + url
  end

  document, url = get_document(url, return_url: true)

  price = document.css("[data-price-type='finalPrice']").first.attribute("data-price-amount").value.strip
  description = document.css("#descrm .description .value").first.text.strip
  number_of_pages = document.css("[data-th='Bladzijden']").first&.text&.strip

  puts isbn
  puts price
  puts description
  puts number_of_pages

  { url: url, price: price, description: description, number_of_pages: number_of_pages }
end

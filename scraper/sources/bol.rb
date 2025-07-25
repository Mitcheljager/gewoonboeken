require_relative "../base"
require "nokogiri"

def scrape_bol(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Bol.com")

  url = listing&.url

  if listing&.url
    puts "Running previously fetched url For Bol for: " + url

    document = get_document(url)
  else
    puts "Running new url for Bol"

    # Bol.com doesn't have nice enough urls to visit them directly via slug + isbn.
    # Instead, we search first and get first result
    base_url = "https://www.bol.com"
    document = get_document("#{base_url}/nl/nl/s/?searchtext=#{isbn}")

    # No search results were returned for this isbn
    if !document.include?(isbn)
      puts "No search results for #{isbn}"
      return { url: nil, available: false }
    end

    # Sometimes pages display with a consent modal over top. When this happens the entire page markup
    # is completely different. Maybe some old version of their page that is shown behind the modal?
    link_element = document.at_css(".grid .flex.w-full a")
    link_element = document.at_css(".product-title") if link_element.blank?

    first_url = link_element&.attribute("href")&.value

    if !document.include?(isbn)
      puts "Search document did not include url for #{isbn}"
      return { url: nil, available: false }
    end

    # Get document again for url that was fetched from search
    url = base_url + first_url
    document = get_document(url)
  end

  return { url: nil, available: false } if document.nil?

  json_element = document.at_css("script[type='application/ld+json']")
  json = JSON.parse(json_element.text)

  description = json["description"]
  number_of_pages = json["workExample"][0]["numberOfPages"]
  price = document.at_css(".price-block__price .promo_price")

  # Only return listing for books actually sold by Bol.com, partners are handled separately
  available = document.text.include?("Verkoop door bol")

  return { url:, available: false, description:, number_of_pages: } if !available

  # The price is shown in two separate elements with a pseudo element as the comma.
  # We get both elements separately and merge them together. Whole prices are shown with a "-".
  price_large = document.at_css(".price-block__price .promo-price").children.first.text.strip
  price_cents = document.at_css(".price-block__price .promo-price__fraction").text.strip.gsub("-", "00")
  price = "#{price_large}.#{price_cents}"

  { url:, price:, description:, number_of_pages:, condition: :new, available: available }
end

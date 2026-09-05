require_relative "../get_document"

def scrape_paagman(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Paagman")

  url = listing&.url

  begin
    throw unless listing&.url

    puts "Running previously fetched url For Paagman for: " + url

    document = get_document(url)

    throw if document.nil?
  rescue
    puts "Running new url for Paagman"

    search_document = get_document("https://www.paagman.nl/zoek?term=#{isbn}", return_url: true)

    if search_document.nil? || search_document.include?("Geen zoekresultaten")
      puts "No search results for #{isbn}"
      return { url: nil, available: false }
    end

    search_item = search_document.at_css("a[href*=#{listing.book.isbn}")
    document = get_document(search_item.attribute("href").value)
  end

  json_element = document.at_css("script[type='application/ld+json']")
  json = JSON.parse(json_element.text)

  description = json["description"]
  price = json["offers"][0].price
  available = json["offers"][0]["availability"] == "InStock"
  number_of_pages = document.at_css("div:contains('Bladzijden:')")&.text&.gsub("Bladzijden:", "")&.strip

  { url:, price:, description:, number_of_pages:, condition: :new, available: }
end

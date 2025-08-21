require_relative "../get_document"

def scrape_amazon_retourdeals(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Amazon") # Deliberately get Amazon rather than Amazon Retourdeals. If Amazon contain no listing, than retourdeals does not either
  amazon_retourdeals_merchant_id = "A3C1D9TG1HJ66Y"

  url = listing&.url

  if url.blank?
    puts "No valid url was found on Amazon RetourDeals for #{isbn}"

    return { url: nil, available: false }
  end

  puts "Using previous set url #{url}"

  document = get_document(url)

  return { url: nil, available: false } unless url.include?("/dp/")

  has_amazon_retour_deals = document.css("#merchant-info:contains('Amazon RetourDeals')")

  if has_amazon_retour_deals
    puts "Amazon page for \"#{isbn}\" does not contain RetourDeals offer"
    return { url: url, condition: :used, available: false }
  end

  price = document.css(".a-accordion-inner:contains('#{amazon_retourdeals_merchant_id}') form input[name*='amount']").first.get_attribute('value')

  { url:, price:, condition: :used, available: true }
end

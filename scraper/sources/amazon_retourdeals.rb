require_relative "../get_document"
require_relative "../helpers/log_message"

def scrape_amazon_retourdeals(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Amazon") # Deliberately get Amazon rather than Amazon Retourdeals. If Amazon contain no listing, than retourdeals does not either

  url = listing&.url

  if url.blank?
    puts "No valid url was found on Amazon RetourDeals for #{isbn}"

    return { url: nil, available: false }
  end

  puts "Using previous set url #{url}"

  document = get_document(url)

  return { url: nil, available: false } unless url.include?("/dp/") || document.nil?

  used_item_node = document.at_css("#usedAccordionRow")
  has_amazon_retour_deals = used_item_node&.text&.include?("Amazon RetourDeals")

  if !has_amazon_retour_deals
    puts "Amazon page for \"#{isbn}\" does not contain RetourDeals offer"
    return { url: url, condition: :used, available: false }
  end

  price = used_item_node.at_css(".a-offscreen")&.text&.tr(",", ".")&.tr("€", "")&.strip
  price_includes_shipping = used_item_node.text.include?("GRATIS bezorging")

  { url:, price:, price_includes_shipping:, condition: :used, available: true }
end

require_relative "../helpers/date_formatter"

def scrape_amazon(isbn)
  listing = find_listing_for_isbn_and_source_name(isbn, "Amazon")

  base_path = "https://www.amazon.nl"
  url = clean_url(listing&.url || "")

  if url.blank?
    puts "Running Amazon search page for #{isbn}"

    document = get_document("#{base_path}/s?k=#{isbn}")

    return { url: nil, available: false } if document.nil? || document&.text&.include?("Geen resultaten")

    first_search_item_path = document.css("[role='listitem'] a").first.attribute("href").value
    url = clean_url(base_path + first_search_item_path)
  end

  if url.blank?
    puts "No valid url was found on Amazon for #{isbn}"
  else
    if listing&.url
      puts "Using previous set url #{url}"
    else
      puts "Using newly fetched url #{url}"
    end

    document = get_document(url)

    return { url: nil, available: false } unless url.include?("/dp/")

    fulfiller = document.css("[offer-display-feature-name='desktop-fulfiller-info'] .offer-display-feature-text").first
    is_amazon = fulfiller&.text&.strip == "Amazon"

    return { url:, available: false } if !is_amazon

    price_text = document.at_css(".swatchElement.selected")&.text
    price = price_text.to_s.gsub(/[^\d,\.]/, "").tr(",", ".")

    if price.blank?
      price_text = document.at_css(".priceToPay span")&.text
      price = price_text.to_s.gsub("€", "").tr(",", ".").strip
    end

    number_of_pages_label = document.css("#detailBullets_feature_div .a-list-item span:contains('pagina')").first
    number_of_pages = number_of_pages_label&.text&.gsub("pagina's", "")&.strip

    description = document.css("#bookDescription_feature_div .a-expander-content").first&.text&.strip
    price_includes_shipping = document.css("#mir-layout-DELIVERY_BLOCK").first&.text&.include?("GRATIS bezorging")
    published_date_text = DateFormatter.format_published_date_text(document.css("#rpi-attribute-book_details-publication_date .rpi-attribute-value").first&.text&.strip)
    available = price_text.present?

    { url:, price:, description:, number_of_pages:, condition: :new, available:, published_date_text:, price_includes_shipping: }
  end
end

def clean_url(url)
  return url unless url.include?("?")
  url.sub(/\/ref=.*/, "") # Remove referal bits after the final ?
end

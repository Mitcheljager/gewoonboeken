require_relative "../get_document"

def scrape_booknext(isbn)
  url = "https://www.booknext.nl/boeken/#{isbn}"
  url, document = get_document(url, return_url: true)

  # Document was not found or it hit some redirect to an overview page
  return { url: nil, available: false } if document.nil? || document.at_css("h1")&.text&.include?("Boeken kopen")
  # Book page is found, but not currently available
  return { url:, available: false } if document.at_css("h3")&.text&.include?("Helaas")

  # .xpath here means only the direct textnode is used. The price might otherwise contain a "x% korting" link.
  price = document.at_css(".bm-detail-buy-item .price")&.xpath('text()')&.text&.tr("€", "")&.gsub(/[[:space:]]/, '')&.strip
  # Used items use a form, new items use a button with the text "Kopen"
  available = document.at_css(".bm-detail-buy-item form").present? || document.at_css(".bm-detail-buy-item .btn.btn-primary")&.text&.include?("Kopen")
  # Compare the full text, as used items may include "Als nieuw"
  condition = document.at_css(".bm-detail-buy-item .state")&.text == "Nieuw" ? :new : :used
  # For new items the label is "Gratis verzonden!", for used items the label includes "gratis verzonden". Always use downcase to check both.
  price_includes_shipping = document.at_css(".bm-detail-buy-item")&.text&.downcase&.include?("gratis verzonden")

  { url:, price:, available:, condition:, price_includes_shipping: }
end

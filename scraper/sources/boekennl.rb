require_relative "../base"
require_relative "../helpers/date_formatter"
require "nokogiri"

def scrape_boekennl(isbn, title)
  listing = find_listing_for_isbn_and_source_name(isbn, "Boeken.nl")

  # Boeken.nl removes certain stop words, they use Drupal with Pathauto. Their full list of English words is considered, as well as some Dutch.
  # List from https://www.drupal.org/docs/extending-drupal/contributed-modules/contributed-modules/contributed-modules-for-managing-urls/pathauto-generate-url-path-aliases-automatically/per-language-strings-to-remove-suggestions
  stop_words = %w[
    a an as at before but by for from is in into like of off on onto per since than the this that to up via with
    voor met op en
  ]
  title_words = title.downcase.gsub("'", "").split
  filtered_words = title_words.reject { |word| stop_words.include?(word) }
  cleaned_title = filtered_words.join(" ")

  slug = cleaned_title.parameterize
  url = listing&.url || "https://boeken.nl/boeken/#{isbn}/#{slug}"

  puts "Running Boeken.nl for: " + url

  document = get_document(url)

  # Document was not an actual page, instead it fell back to some overview page
  # In this case we use a search engine to find the actual page, if it exists
  url, document = get_search_document("boeken.nl", isbn) unless document&.text&.include?("Beoordelingen")

  return { url: nil, available: false } if url.blank? || document.blank?

  is_ebook = document.at_css("h1").text.include?("(e-book)")

  return { url: nil, available: false } if is_ebook

  price = document.css(".product-info .uc-price").first.text.gsub("€", "").gsub(",", ".").strip
  description = document.css(".field-name-body .nxte-shave-expanding-item").first&.text&.strip
  number_of_pages = document.css(".field-name-field-page-count .field-item").first&.text&.strip

  published_date_text = DateFormatter.format_published_date_text(document.css(".field-name-field-publishing-date .date-display-single").first&.text&.strip)

  { url:, price:, description:, number_of_pages:, available: !price.blank?, condition: :new, published_date_text: }
end

require 'httparty'
require 'base64'

def scrape_bol(isbn)
  token = get_bol_access_token()

  product = get_bol_response(token, isbn, "?country-code=NL&include-offer=true&include-specifications=true&include-seller=true")
  return { url: nil, available: false } if product.nil? || product["ean"].nil?

  url = product["url"]

  seller_info = get_bol_response(token, isbn, "/offers/best?country-code=NL&include-seller=true")
  return { url:, available: false } if seller_info.nil?

  description = product["description"]
  number_of_pages = get_bol_number_of_pages(product)

  price = product.dig("offer", "price")
  price_includes_shipping = get_bol_book_language(product) == "nl" # All dutch books include shipping
  available = price.present? && seller_info.dig("seller", "name") == "bol.com"

  { url:, available:, description:, number_of_pages:, price:, condition: :new, price_includes_shipping: }
end

def get_bol_access_token
  auth = Base64.strict_encode64("#{ENV["BOL_CLIENT_ID"]}:#{ENV["BOL_CLIENT_SECRET"]}")

  response = HTTParty.post(
    "https://login.bol.com/token?grant_type=client_credentials",
    headers: {
      "Authorization" => "Basic #{auth}",
      "Accept" => "application/json",
      "Content-Length" => "0"
    }
  )

  if response.code != 200
    puts "Bol.com token request failed: #{response.code} - #{response.body}"
    return
  end

  response.parsed_response["access_token"]
end

def get_bol_response(token, isbn, path)
  response = HTTParty.get(
    "https://api.bol.com/marketing/catalog/v1/products/#{isbn}#{path}",
    headers: {
      "Authorization" => "Bearer #{token}",
      "Accept" => "application/json",
      "Accept-Language" => "nl"
    }
  )

  return nil if response.code != 200

  response.parsed_response
end

def get_bol_book_language(product)
  language = nil

  groups = product["specificationGroups"] || []
  content_group = groups.find { |g| g["title"] == "Inhoud" }

  if content_group
    language_specification = content_group["specifications"].find { |s| s["key"] == "Language" }
    language = language_specification["values"].first if language_specification
  end

  language
end

def get_bol_number_of_pages(product)
  product["specificationGroups"]&.find { |group|
    group["title"] == "Inhoud"
  }&.dig("specifications")&.find { |spec|
    spec["name"] == "Aantal pagina's"
  }&.dig("values")&.first
end

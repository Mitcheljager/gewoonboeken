require_relative "../get_document"
require "nokogiri"

def get_goodreads_data(isbn)
  goodreads_search_url = "https://www.goodreads.com/search?q=#{isbn}"

  puts "Running Goodreads for: #{goodreads_search_url}"

  document = get_document(goodreads_search_url)

  # Goodreads data is available in a JSON object from Nextjs, but it's not super easy to read
  json_element = document&.at_css("#__NEXT_DATA__")

  if json_element&.blank?
    puts "No Goodreads page was found for #{isbn}"
    return nil
  end

  json = JSON.parse(json_element.text)
  json_details = extract_first_book_details(json["props"]["pageProps"]["apolloState"])

  authors = extract_book_authors(json["props"]["pageProps"]["apolloState"])
  genres = extract_book_genres(json["props"]["pageProps"]["apolloState"])
  title = extract_book_title(json["props"]["pageProps"]["apolloState"])

  # Format can be nil in some cases
  is_ebook = json_details["format"]&.include?("Kindle") || json_details["format"]&.include?("ebook") || false
  language_text = json_details["language"]&.[]("name")
  publication_time = json_details["publicationTime"]
  published_date = publication_time ? Time.at(publication_time / 1000).to_date.strftime("%Y-%m-%d") : nil

  language = nil
  language = "nl" if language_text&.include?("Dutch")
  language = "en" if language_text&.include?("English")

  # We could get these values from the JSON object above, but this felt pretty easy
  format_text = document.css("[data-testid='pagesFormat']").text
  format = "unknown"
  format = "paperback" if format_text&.include?("Paperback")
  format = "hardcover" if format_text&.include?("Hardcover")

  image_url = document.css(".BookCover__image img")&.first&.attribute("src")&.value
  image_url = nil if image_url&.include?("no-cover")

  { genres:, format:, image_url:, is_ebook:, title:, language:, authors:, published_date: }
end

# The json object contains multiple "Book:" keys with values, but only one of these has
# a details object with a format key, that will be the primary book on the page.
def extract_first_book_details(json)
  json.each do |key, value|
    next unless key.start_with?("Book:")
    next unless value["details"].present?

    return value["details"]
  end

  {}
end

# Each page contains multiple contributors, each contributor with a name value is assumed
# to be an author.
def extract_book_authors(json)
  authors = []

  json.each do |key, value|
    next unless key.start_with?("Contributor:")
    next unless value["name"].present?

    authors << value["name"]
  end

  authors
end

# Genres are present in an object that is different from the details object above.
# This object contains a bookGenres key, which has an array of genres as value.
# This array looks roughly like [{ __typeName: "BookGenre", genre: { name: "Some genre name" } }]
def extract_book_genres(json)
  genres = []

  json.each do |key, value|
    next unless key.start_with?("Book:")
    next unless value["bookGenres"]

    value["bookGenres"].each do |item|
      genres << item["genre"]["name"]
    end
  end

  genres
end

# The title is present in the same object as the genres. We could be clever and extract that logic,
# or we just repeat it, because why not.
def extract_book_title(json)
  json.each do |key, value|
    next unless key.start_with?("Book:")
    next unless value["title"]

    return value["title"]
  end

  nil
end

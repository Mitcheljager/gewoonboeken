require_relative "../config/environment"
require_relative "get_book"
require_relative "helpers/log_time"
require_relative "sources/amazon"
require_relative "sources/amazon_retourdeals"
require_relative "sources/boekenbalie"
require_relative "sources/boekenkraam"
require_relative "sources/boekennl"
require_relative "sources/bol"
require_relative "sources/booknext"
require_relative "sources/broese"
require_relative "sources/bruna"
require_relative "sources/deslegte"
require_relative "sources/donner"
require_relative "sources/libris"
require_relative "sources/paagman"
require_relative "sources/readshop"
require_relative "sources/voordeelboekenonline"

puts "Running scrapers..."

def run_scraper(source_name, sources_to_run, isbn, title)
  return unless is_in_run?(sources_to_run, source_name)

  puts "Running #{source_name}..."

  begin
    result = yield || {}

    save_result(source_name, isbn, **result)
    update_listing_scraping_status(source_name, isbn, was_successful: true)

    color = result[:available] ? "\e[32m" : "\e[31m"
    puts "Available on #{source_name}:#{color} #{result[:available]} \e[0m"
  rescue => error
    puts "\e[31m"
    puts "#{source_name} failed for: #{title} - #{isbn}"
    puts "#{error.class}: #{error.message}"
    puts error.backtrace.join("\n")
    puts "\e[0m"

    save_unsuccessful_result(source_name, isbn)
    update_listing_scraping_status(source_name, isbn, was_successful: false)
  ensure
    result = nil
    puts "---"
  end
end

def run_all_scrapers(isbn, sources_to_run)
  begin
    book = start_book(isbn)

    return if book.blank?

    isbn = book.isbn
    title = book.title

    # Titles are only passed to scrapers that we can build a url for. Those tend to be some combination of the slugified title
    # and the isbn. For websites do not contain the isbn in the title and at that point the title slug won't help either.
    run_scraper("Amazon", sources_to_run, isbn, title)                  { scrape_amazon(isbn) }
    run_scraper("Amazon RetourDeals", sources_to_run, isbn, title)      { scrape_amazon_retourdeals(isbn) }
    run_scraper("Boekenbalie", sources_to_run, isbn, title)             { scrape_boekenbalie(isbn, title) }
    run_scraper("Boekenkraam", sources_to_run, isbn, title)             { scrape_boekenkraam(isbn) }
    run_scraper("Boeken.nl", sources_to_run, isbn, title)               { scrape_boekennl(isbn, title) }
    run_scraper("Bol.com", sources_to_run, isbn, title)                 { scrape_bol(isbn) }
    run_scraper("Booknext", sources_to_run, isbn, title)                { scrape_booknext(isbn) }
    run_scraper("Broese", sources_to_run, isbn, title)                  { scrape_broese(isbn) }
    run_scraper("Bruna", sources_to_run, isbn, title)                   { scrape_bruna(isbn, title) }
    run_scraper("De Slegte", sources_to_run, isbn, title)               { scrape_deslegte(isbn) }
    run_scraper("Donner", sources_to_run, isbn, title)                  { scrape_donner(isbn) }
    run_scraper("Paagman", sources_to_run, isbn, title)                 { scrape_paagman(isbn) }
    run_scraper("Readshop", sources_to_run, isbn, title)                { scrape_readshop(isbn, title) }
    run_scraper("Voordeelboekenonline.nl", sources_to_run, isbn, title) { scrape_voordeelboekenonline(isbn) }
    # [Broken, CF 403] run_scraper("Libris", isbn, title)                  { scrape_libris(isbn) }
  rescue => error
    Rails.logger.error("Error in run_all_scrapers")
    Rails.logger.error("#{error.class}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
  ensure
    end_book(isbn)
  end
end

def save_result(source_name, isbn, url:, price: 0, currency: "EUR", description: nil, number_of_pages: 0, condition: :unknown, condition_details: nil, available: true, published_date_text: nil, price_includes_shipping: false, last_search_api_request_at: nil)
  book = get_book(isbn)

  raise "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = Float(price || 0)
  listing.currency = currency
  listing.url = url
  listing.number_of_pages = number_of_pages
  listing.description = description
  listing.condition = condition
  listing.condition_details = condition_details
  listing.available = available
  listing.published_date_text = published_date_text if published_date_text.present?
  listing.last_search_api_request_at = last_search_api_request_at if last_search_api_request_at.present?
  listing.price_includes_shipping = price_includes_shipping

  listing.save
end

# An unsuccessful result means the scrape returned errors. It doesn't mean the scrape simply found nothing.
# Finding nothing is perfectly valid and should be handled in save_result by setting available to false
def save_unsuccessful_result(source_name, isbn)
  book = get_book(isbn)

  raise "Book was nil" if book.nil?

  source = Source.find_by_name(source_name)

  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)
  listing.price = 0
  listing.currency = nil
  listing.url = nil
  listing.available = false

  listing.save
end

def update_listing_scraping_status(source_name, isbn, was_successful:)
  book = Book.find_by_isbn(isbn)
  source = Source.find_by_name(source_name)
  listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)

  listing.last_scraped_at = DateTime.now
  listing.was_last_scrape_successful = was_successful

  listing.save!
end

def start_book(isbn)
  book = get_book(isbn)
  book.update!(last_scrape_started_at: DateTime.now)

  book
end

def end_book(isbn)
  book = Book.find_by_isbn!(isbn)

  consolidate_number_of_pages(book)
  consolidate_published_date_text(book)

  book.update(last_scrape_finished_at: DateTime.now)
end

def consolidate_number_of_pages(book)
  number_of_pages_counts = book.listings.where.not(number_of_pages: 0).pluck(:number_of_pages)
  most_common_number_of_pages = number_of_pages_counts.group_by(&:itself).transform_values(&:count).max_by { |_, count| count }&.first

  return if number_of_pages_counts.empty?

  if most_common_number_of_pages && book.number_of_pages != most_common_number_of_pages
    book.update(number_of_pages: most_common_number_of_pages)
  end
end

# In some cases books scraped from Goodreads don't have published dates, but listings might have them
def consolidate_published_date_text(book)
  return if book.published_date_text.present?

  published_date_text_counts = book.listings.where.not(published_date_text: nil).pluck(:published_date_text)
  most_common_published_date_text = published_date_text_counts.group_by(&:itself).transform_values(&:count).max_by { |_, count| count }&.first

  return if published_date_text_counts.empty?

  if most_common_published_date_text && book.number_of_pages != most_common_published_date_text
    book.update(published_date_text: most_common_published_date_text)
  end
end

# If any sources are given, return true if current sources is given.
# Otherwise check if source is disabled during every run.
# We check it on each run so that we can disable source while a run is ongoing.
def is_in_run?(sources_to_run, name)
  return sources_to_run.include?(name) if sources_to_run.present?

  source = Source.find_by_name!(name)
  !source.disabled?
end

start_time = DateTime.now

arguments = ARGV.map { |a| a.split("=", 2) }.to_h
isbn = arguments["isbn"]
sources_to_run = arguments["sources"]&.split(",") || []
hours_ago = arguments["hours_ago"]&.to_i

if isbn.present?
  run_all_scrapers(isbn, sources_to_run)
else
  hours_ago_time = hours_ago.present? ? Time.now - hours_ago.hours : nil
  books = hours_ago_time.present? ? Book.where('last_scrape_finished_at < ? OR last_scrape_finished_at IS NULL', hours_ago_time) : Book.all

  books.each_with_index do |book, index|
    puts "-----------------------------------------------------"
    puts "Running scrapers for \e[35m\"#{book.title}\"\e[0m | \e[4m#{book.isbn}\e[0m | \e[44m #{index + 1} out of #{books.size} \e[0m"
    puts "-----------------------------------------------------"

    ActiveRecord::Base.connection_pool.with_connection do
      run_all_scrapers(book.isbn, sources_to_run)
    end

    # Run garbage collection after every 10 books to clear up memory from each run
    if index % 10 == 0
      puts "Garbage collection..."
      GC.start
    end
  end
end

LogTime.log_end_time(start_time)

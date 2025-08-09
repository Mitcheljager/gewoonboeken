require_relative "../get_book"
require_relative "../get_document"
require_relative "../helpers/log_time"

GC.enable

isbn_list = []
start_time = DateTime.now

# Bol.com - 30 entries per page, 100 pages, many subpaths
subpaths = [
  "thrillers-en-spannende-boeken/2551",
  "detectives/40637",
  "horror-en-bovennatuurlijke-thrillers/40414",
  "psychologische-thrillers/40643",
  "literatuur-romans-boek/24410",
  "geschiedenisboeken-boek/40347",
  "boeken-over-religie-spiritualiteit-filosofie-boek/2562",
  "boeken-over-wetenschap-en-natuur-boek/23952",
  "literaire-klassiekers/40491",
  "oorlogsromans/41285",
  "romanceboeken/40494",
  "streekromans/40498",
  "speculatieve-romans/40495"
]

subpaths.each do |subpath|
  # 8292 is English, 8293 is Dutch
  languages = ["8292", "8293"]
  languages.each do |language|
    for page in 1..10 do
      # + 11209 is the category for books, which means we exclude Ebooks and Audiobooks
      document = get_document("https://www.bol.com/nl/nl/l/#{subpath}/#{language}+11209/?page=#{page}")

      next if document.nil?

      document.css(".product-item__content, #mainContent .flex-row .grid .min-w-none").each do |node|
        next if node.include?("Ebook") # Specifically Ebook, not e-book, as that would include the other variant sections

        # Find any 13 digit code, presumably the ISBN
        match = node.to_s.match(/\b\d{13}\b/)
        next unless match.present?

        isbn_list << match[0]
      end

      # Set document to nil so we garbage collect it later
      document = nil
    end
  end

  puts "Garbage collection..."
  GC.start
end

# Boeken.nl - 100 entries per page, 50 pages, starts at 0
# Requests can be super slow, so timeout is extended
for page in 0..50 do
  document = get_document("https://www.boeken.nl/boeken?page=#{page}&field_format_tid_entityreference_filter%5B0%5D=18&field_format_tid_entityreference_filter%5B1%5D=655&nxte_complete_price%5Bmin%5D=&nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B0%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B1%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-keys_optional=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters", timeout: 10)
  next if document.nil?

  document.css(".views-row a").each do |node|
    # The only place the isbn is present on these overview pages is in the URLs of each book
    url = node.attribute("href").value
    next if url.blank?

    isbn = url.match(%r{/(\d{13})/})&.captures&.first
    next if isbn.blank?

    isbn_list << isbn
  end

  document = nil

  if page % 10 == 0
    puts "Garbage collection..."
    GC.start
  end
end

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each_with_index do |isbn, index|
  puts "\e[44m #{index} out of #{isbn_list.count} \e[0m"

  begin
    book = get_book(isbn, attach_image: true)

    raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
  rescue => error
    puts "Book with #{isbn} failed to be indexed from get_various_books.rb"
    puts error

    # Show full backtrace but skip for RuntimeErrors, as those would have been manually triggered "raise" errors,
    # which we can safely(?) ignore.
    puts error.backtrace.join("\n") if error.class.to_s != "RuntimeError"
  end

  # Reset book and run Garbage collector for every 20 indexes
  book = nil

  if index % 20 == 0
    puts "Garbage collection..."
    GC.start
  end
end

LogTime.log_end_time(start_time)

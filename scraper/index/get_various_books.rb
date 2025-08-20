require_relative "../get_book"
require_relative "../get_document"
require_relative "../helpers/log_time"
require_relative "../index/index_listing_url"

GC.enable

isbn_list = []
start_time = DateTime.now

# ! Bol.com - 30 entries per page, 100 pages, many subpaths
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

# ! Boeken.nl - 100 entries per page, 50 pages, starts at 0
# Requests can be super slow, so timeout is extended
for page in 0..50 do
  base_url = "https://www.boeken.nl"
  document = get_document("#{base_url}/boeken?page=#{page}&field_format_tid_entityreference_filter%5B0%5D=18&field_format_tid_entityreference_filter%5B1%5D=655&nxte_complete_price%5Bmin%5D=&nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B0%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B1%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-keys_optional=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters", timeout: 10)

  next if document.nil?

  document.css(".views-row h3 a").each do |node|
    # The only place the isbn is present on these overview pages is in the URLs of each book
    path = node.attribute("href").value
    next if path.blank?

    isbn = path.match(%r{/(\d{13})/})&.captures&.first
    next if isbn.blank?

    index_listing_url("Boeken.nl", isbn, base_url + path)

    isbn_list << isbn
  end

  document = nil

  if page % 10 == 0
    puts "Garbage collection..."
    GC.start
  end
end

# ! Donner.nl - 12 entries per page, several subpaths, 50 pages each
subpaths = [
  "fictie/",
  "fictie/literatuur/",
  "fictie/romantisch/",
  "fictie/spanning-thrillers/",
  "fictie/fantasy-sciencefiction/",
  "non-fictie/",
  "non-fictie/economie-management/",
  "kunst-cultuur/",
  "vrije-tijd/",
  "vrije-tijd/koken/",
  "vrije-tijd/natuur-tuin/"
]

subpaths.each do |subpath|
  for page in 1..50 do
    base_url = "https://www.donner.nl"
    document = get_document("#{base_url}/boeken/#{subpath}?page=#{page}")

    next if document.nil?

    document.css(".search-result").each do |node|
      # Overview pages might include a variety of formats, including ebooks, dvds, games, and more.
      next unless node.text.include?("Paperback") || node.text.include?("Hardback") # They call it "hardback / gevonden" rather than "hardcover"
      next unless node.text.include?("Engels") || node.text.include?("Nederlands") # Donner offers books in many languages. We only care for Dutch and English.

      path = node.at_css("a")&.attribute("href")&.value
      next if path.blank? # Not sure if it can be blank, but who knows

      isbn = node.attribute("data-ean").value
      next if isbn.blank? # Same here, maybe it can be blank, no clue

      index_listing_url("Donner", isbn, base_url + path)

      isbn_list << isbn
    end

    document = nil

    if page % 10 == 0
      puts "Garbage collection..."
      GC.start
    end
  end
end

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
batch_size = 20
total_index = 0
isbn_list.each_slice(batch_size).with_index do |batch, batch_index|
  puts "\e[45m Processing batch #{batch_index + 1} / #{(isbn_list.size / batch_size).ceil} \e[0m"

  batch.each do |isbn|
    puts "\e[44m #{total_index} out of #{isbn_list.count} \e[0m"

    ActiveRecord::Base.connection_pool.with_connection do
      begin
        book = get_book(isbn, attach_image: true)

        raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
      rescue => error
        puts "Book with #{isbn} failed to be indexed from get_various_books.rb"
        puts error

        # Show full backtrace but skip for RuntimeErrors, as those would have been manually triggered "raise" errors,
        # which we can safely(?) ignore.
        puts error.backtrace.join("\n") if error.class.to_s != "RuntimeError"
      ensure
        total_index += 1
        # Reset for garbage collection later
        book = nil
      end
    end
  end

  puts "Garbage collection..."
  GC.start
end

LogTime.log_end_time(start_time)

require_relative "../get_book"
require_relative "../get_document"
require_relative "../helpers/log_time"
require_relative "../index/index_listing_url"

GC.enable

isbn_list = []
start_time = DateTime.now

# ! Boeken.nl - Different pages for different authors, each with up to 100 results.
slugs = [
  "stephen-king",
  "karin-slaughter",
  "jk-rowling",
  "roald-dahl",
  "haruki-murakami",
  "jrr-tolkien",
  "george-rr-martin",
  "george-orwell",
  "paul-van-loon",
  "patrick-rothfuss",
  "agatha-christie",
  "saskia-noort",
  "anya-niewierra"
]

slugs.each do |slug|
  # Requests can be super slow, so timeout is extended
  document = get_document("https://www.boeken.nl/schrijver/#{slug}?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters", timeout: 10)

  next if document.nil?

  document.css(".views-row h3 a").each do |node|
    # The only place the isbn is present on these overview pages is in the URLs of each book
    path = node.attribute("href").value
    next if path.blank?

    isbn = path.match(%r{/(\d{13})/})&.captures&.first
    next if isbn.blank?

    index_listing_url("Boeken.nl", isbn, "https://www.boeken.nl" + path)

    isbn_list << isbn
  end

  document = nil
end

# ! Donner.nl - 12 entries per page 20 pages each

# Slugs are close to that of boeken.nl, but not always the same
slugs = [
  "stephen-king",
  "karin-slaughter",
  "j-k-rowling",
  "roald-dahl",
  "haruki-murakami",
  "j-r-r-tolkien",
  "george-r-r-martin",
  "george-orwell",
  "paul-van-loon",
  "patrick-rothfuss",
  "agatha-christie",
  "saskia-noort",
  "anya-niewierra"
]

slugs.each do |slug|
  for page in 1..20 do
    base_url = "https://www.donner.nl"
    document = get_document("#{base_url}/auteurs/#{slug}?page=#{page}")

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

GC.start

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.uniq.each_with_index do |isbn, index|
  puts "\e[44m #{index + 1} out of #{isbn_list.count} \e[0m"

  ActiveRecord::Base.connection_pool.with_connection do
    begin
      book = get_book(isbn, attach_image: true)

      raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
    rescue => error
      puts "Book with #{isbn} failed to be indexed from get_books_via_authors.rb"
      puts error

      # Show full backtrace but skip for RuntimeErrors, as those would have been manually triggered "raise" errors,
      # which we can safely(?) ignore.
      puts error.backtrace.join("\n") if error.class.to_s != "RuntimeError"
    ensure
      # Reset for garbage collection later
      book = nil
    end
  end

  puts "Garbage collection..."
  GC.start
end

LogTime.log_end_time(start_time)

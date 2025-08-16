require_relative "../get_book"
require_relative "../get_document"
require_relative "../index_listing_url"
require_relative "../helpers/log_time"

# This is a hash containing all collected ISBNs with a popularity score. Higher == better.
isbn_list = Hash.new(0)

start_time = DateTime.now
index = 0

# Bestseller60 - 60 entries
document = get_document("https://www.debestseller60.nl/")
document.css(".card__tags__tag").each do |node|
  # The selector above contains all sorts of tags, not just ISBNs
  next unless node.text.include?("ISBN")

  isbn = node.text.gsub("ISBN", "").strip
  next if isbn.blank?

  # Score weighs a bit higher than others might since it's limited to 60 entries
  score = [240 - (index * 4), 1].max
  isbn_list[isbn] += score

  index += 1
end

# Bol.com - 30 entries per page, 10 pages

index = 0

for page in 1..10 do
  # + 11209 is the category for books, which means we exclude Ebooks and Audiobooks
  document = get_document("https://www.bol.com/nl/nl/l/boeken/8299/11209/?page=#{page}")
  next if document.nil?

  document.css(".product-item__content, #mainContent .flex-row .grid .min-w-none").each do |node|
    next if node.include?("Gesponsord")
    next if node.include?("Ebook") # Specifically Ebook, not e-book, as that would include the other variant sections

    # Find any 13 digit code, presumably the ISBN
    match = node.to_s.match(/\b\d{13}\b/)
    next unless match.present?

    score = [200 - (page * 30) - index * 3, 1].max
    isbn_list[match[0]] += score

    index += 1
  end
end

index = 0

# Boeken.nl - 100 entries per page, 3 pages, starts at 0
for page in 0..2 do
  base_url = "https://www.boeken.nl"
  document = get_document("#{base_url}/boeken/top-100?page=#{page}&mefibs-form-view-options-bottom-keys=&mefibs-form-view-options-bottom-items_per_page=100&mefibs-form-view-options-bottom-mefibs_block_id=view_options_bottom")

  next if document.nil?

  document.css(".views-row h3 a").each do |node|
    # The only place the isbn is present on these overview pages is in the URLs of each book
    path = node.attribute("href").value
    next if path.blank?

    isbn = path.match(%r{/(\d{13})/})&.captures&.first
    next if isbn.blank?

    index_listing_url("Boeken.nl", isbn, base_url + path)

    score = [200 - index, 1].max
    isbn_list[isbn] += score

    index += 1
  end
end

index = 0

# Bruna.nl - 100 entries
document = get_document("https://www.bruna.nl/boeken-top-100")
document.css(".ankeiler-wrapper [data-test-id='titleAndSubtitle'] a").each do |node|
  # The only place the isbn is present on these overview pages is in the URLs of each book
  url = node.attribute("href").value

  next if url.blank?
  next if !url.include?("/boeken/")

  isbn = url.match(/(\d{10,13})(?:$|\D)/)&.captures&.first
  next if isbn.blank?

  score = [200 - (index * 2), 1].max
  isbn_list[isbn] += score

  index += 1
end

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each_with_index do |(isbn, score), index|
  puts "\e[44m #{index + 1} out of #{isbn_list.count} \e[0m"

  begin
    book = get_book(isbn, attach_image: true)

    book.update(hotness: score) unless book.hotness == score
    raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
  rescue => error
    puts "Book with #{isbn} failed to be indexed from get_popular_books.rb"
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

# Reset the hotness of all books with hotness that were not included in the list above.
isbns = isbn_list.map(&:first)
Book.where.not(isbn: isbns).where.not(hotness: 0).update_all(hotness: 0)

LogTime.log_end_time(start_time)

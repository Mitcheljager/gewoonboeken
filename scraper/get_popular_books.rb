require_relative "base"

# This is a hash containing all collected ISBNs with a popularity score. Higher == better.
isbn_list = Hash.new(0)

# Bestseller60 - 60 entries
document = get_document("https://www.debestseller60.nl/")
document.css(".card__tags__tag").each_with_index do |node, index|
  # The selector above contains all sorts of tags, not just ISBNs
  next unless node.text.include?("ISBN")

  isbn = node.text.gsub("ISBN", "").strip
  next if isbn.blank?

  score = 60 - index
  isbn_list[isbn] += score
end

# Bol.com - 30 entries per page, 3 pages
for page in 1..3 do
  document = get_document("https://www.bol.com/nl/nl/l/boeken/8299")
  document.css(".product-item__content").each do |node|
    next if node.include?("Gesponsord")
    next if node.include?("Ebook") # Specifically Ebook, not e-book, as that would include the other variant sections

    # Find any 13 digit code, presumably the ISBN
    match = node.to_s.match(/\b\d{13}\b/)
    isbn_list[match[0]] += 0 if match
  end
end

# Boeken.nl - 100 entries per page, 2 pages
for page in 1..2 do
  document = get_document("https://www.boeken.nl/boeken/top-100?page=#{page}&mefibs-form-view-options-bottom-keys=&mefibs-form-view-options-bottom-items_per_page=100&mefibs-form-view-options-bottom-mefibs_block_id=view_options_bottom")
  document.css(".views-row a").each do |node|
    # The only place the isbn is present on these overview pages is in the URLs of each book
    url = node.attribute("href").value

    next if url.blank?

    isbn = url.match(%r{/(\d{10,13})/})&.captures&.first

    next if isbn.blank?
    next if isbn_list.include?(isbn)

    isbn_list[isbn] += 0
  end
end

# Bruna.nl - 100 entries
document = get_document("https://www.bruna.nl/boeken-top-100")
document.css(".ankeiler-wrapper [data-test-id='titleAndSubtitle'] a").each do |node|
  # The only place the isbn is present on these overview pages is in the URLs of each book
  url = node.attribute("href").value

  next if url.blank?
  next if !url.include?("/boeken/")

  isbn = url.match(/(\d{10,13})(?:$|\D)/)&.captures&.first

  next if isbn.blank?
  next if isbn_list.include?(isbn)

  isbn_list[isbn] += 0
end

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each do |isbn, score|
  skippable = SkippableISBN.find_by_isbn(isbn)

  # An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
  # entry, or because the book was an ebook.
  if skippable.present?
    puts "Skipped #{isbn}"
    next
  end

  begin
    book = get_book(isbn, attach_image: true)

    book.update(hotness: score)
    raise "No book was returned from get_book with isbn #{isbn}" if book.nil?
  rescue => error
    puts "Book with #{isbn} failed to be indexed from get_popular_books.rb"
    puts error

    # Show full backtrace but skip for RuntimeErrors, as those would have been manually triggered "raise" errors,
    # which we can safely(?) ignore.
    puts error.backtrace.join("\n") if error.class.to_s != "RuntimeError"
  end

  # Wait 1 seconds to prevent hitting rate limits on the Google API, which is limited to 100 requests a minute.
  # It's also limited to 1000 per day, but that's another issue.
  # sleep 1
end

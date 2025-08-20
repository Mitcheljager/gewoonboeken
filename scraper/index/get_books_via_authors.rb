require_relative "../get_book"
require_relative "../get_document"
require_relative "../helpers/log_time"
require_relative "../index/index_listing_url"

GC.enable

isbn_list = []
start_time = DateTime.now

urls = [
  "https://www.boeken.nl/schrijver/stephen-king?mefibs-form-view-options-bottom-title=&mefibs-form-view-options-bottom-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-options-bottom-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-options-bottom-nxte_complete_price%5Bmin%5D=&mefibs-form-view-options-bottom-nxte_complete_price%5Bmax%5D=&mefibs-form-view-options-bottom-sort_by=popularity&mefibs-form-view-options-bottom-items_per_page=100&mefibs-form-view-options-bottom-mefibs_block_id=view_options_bottom",
  "https://www.boeken.nl/schrijver/karin-slaughter?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/jk-rowling?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/roald-dahl?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/haruki-murakami?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/jrr-tolkien?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/george-rr-martin?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/george-orwell?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/paul-van-loon?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/patrick-rothfuss?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=18&mefibs-form-view-filters-field_format_tid_entityreference_filter%5B%5D=655&mefibs-form-view-filters-nxte_complete_price%5Bmin%5D=&mefibs-form-view-filters-nxte_complete_price%5Bmax%5D=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters",
  "https://www.boeken.nl/schrijver/anya-niewierra?mefibs-form-view-filters-title=&mefibs-form-view-filters-field_format_tid_entityreference_filter[]=18&mefibs-form-view-filters-field_format_tid_entityreference_filter[]=655&mefibs-form-view-filters-nxte_complete_price[min]=&mefibs-form-view-filters-nxte_complete_price[max]=&mefibs-form-view-filters-sort_by=popularity&mefibs-form-view-filters-items_per_page=100&mefibs-form-view-filters-mefibs_block_id=view_filters"
]

# ! Boeken.nl - Different pages for different authors, each with up to 100 results.
urls.each do |url|
  # Requests can be super slow, so timeout is extended
  document = get_document(url, timeout: 10)

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

GC.start

# An ISBN has previously attempted to be indexed but failed. It could have failed because there was no Goodreads
# entry, or because the book was an ebook.
isbn_list.reject! { |isbn| SkippableISBN.exists?(isbn: isbn) }

# Process all indexed ISBNs, skipping any that are invalid
isbn_list.each_with_index do |isbn, index|
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

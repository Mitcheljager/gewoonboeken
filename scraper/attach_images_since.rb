require_relative "../config/environment"
require_relative "data/goodreads"
require_relative "get_book"
require_relative "attach_remote_image"

hours_ago = ARGV[0].to_i

hours_ago_time = Time.now - hours_ago.hours
books = Book.where('created_at > ?', hours_ago_time)

books.each_with_index do |book, index|
  puts "(#{index + 1} / #{books.size}) Finding and attaching image for #{book.isbn}..."

  book = get_book(book.isbn)
  data = get_goodreads_data(book.isbn)

  if data[:image_url].present?
    begin
      attach_remote_image(book, data[:image_url])
    rescue => error
      puts error
    end
  else
    puts "No valid image url was found for \"#{book.title}\" (#{book.isbn})"
  end
end

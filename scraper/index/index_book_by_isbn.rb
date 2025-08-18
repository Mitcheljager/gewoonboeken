require_relative "../get_book"
require_relative "../helpers/log_message"

isbn = ARGV[0]

begin
  if Book.find_by_isbn(isbn).present?
    puts "Book #{isbn} is already present"
    return
  end

  book = get_book(isbn, attach_image: true)
  puts "Successfully indexed book \"#{book.title}\" (#{book.isbn})"
rescue => error
  LogMessage.log_error_block(message: "Indexing of book #{isbn} was not successful", error:)
end

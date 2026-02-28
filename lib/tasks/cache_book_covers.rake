desc "Cache cover URLs for all books with attached cover images"
task cache_book_covers: :environment do
  Rails.logger = Logger.new($stdout)

  books = Book.with_attached_cover_image.where.not(cover_image_attachment: nil)
  total = books.count

  index = 0
  books.find_each(batch_size: 100) do |book|
    print "Caching cover for book #{index + 1}/#{total}\n"

    begin
      book.cache_cover_urls
    rescue => error
      print "Skipped: #{error.message}\n"
    end

    index += 1
  end

  puts "Cached all book covers"
end

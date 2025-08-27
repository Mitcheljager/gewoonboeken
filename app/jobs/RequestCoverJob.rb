class RequestCoverJob < ApplicationJob
  def perform(isbn, force: false)
    puts "Requesting cover for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    return if book.cover_last_scraped_at.present? && !force

    book.update(cover_last_scraped_at: DateTime.now)

    begin
      system("ruby", Rails.root.join("scraper/attach_image_for_isbn.rb").to_s, book.isbn.to_s)
    rescue => error
      Rails.logger.error(error)
    end
  end
end

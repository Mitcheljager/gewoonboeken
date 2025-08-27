class RequestDescriptionJob < ApplicationJob
  def perform(isbn, force: false)
    puts "Requesting description for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    return if book.description_last_generated_at.present? && !force

    book.update!(description_last_generated_at: DateTime.now)

    begin
      system("ruby", Rails.root.join("scraper/ai/openai_descriptions.rb").to_s, "isbn=#{book.isbn}")
    rescue => error
      Rails.logger.error(error)
    end
  end
end

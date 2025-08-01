require "sidekiq"

class RequestDescriptionJob
  include Sidekiq::Job

  def perform(isbn, force: false)
    puts "Requesting description for #{isbn}"

    book = Book.find_by_isbn!(isbn)

    return if book.description_last_generated_at.present? && !force

    book.update!(description_last_generated_at: DateTime.now)

    begin
      output = `ruby #{Rails.root.join("scraper/ai/openai_descriptions.rb")} #{book.isbn}`
      Rails.logger.info output
    rescue => error
      puts error
    end
  end
end

class BooksController < ApplicationController
  before_action :set_book, only: [:show, :listings_summary_partial, :request_scrape]
  before_action :redirect_isbn, only: [:index]

  # after_action :request_description, only: [:show]
  # after_action :request_cover, only: [:show]

  def index
    @books = BookFilter.new(Book.overview_join, filter_params).filter.page(params[:page])
    @genres = Genre.includes(subgenres: { subgenres: { subgenres: :subgenres } }).where(parent_genre_id: nil)
  end

  def show
  end

  # A js request is made to this method when book.requires_scrape? is true.
  # This is done through js rather than before_action so as not to call it on prefetch or when bots visit the page.
  def request_scrape
    return unless @book.requires_scrape?

    puts "Requested new scrape"

    RequestScrapeJob.perform_later(@book.isbn)
  end

  def listings_summary_partial
    return head :gateway_timeout if @book.is_scrape_ongoing? && @book.last_scrape_started_at < 90.seconds.ago
    return head :no_content if @book.requires_scrape? || @book.is_scrape_ongoing?

    render partial: "book_listings_summary"
  end

  private

  def set_book
    isbn = params.expect([:slug_and_isbn]).split("-").last
    @book = Book.full_join.find_by_isbn!(isbn)
    @listings = @book.listings_with_price_sorted
  end

  def redirect_isbn
    return unless params[:query]

    is_isbn = params[:query].match?(/\A97[89]\d{10}\z/)

    return unless is_isbn

    book = Book.find_by_isbn(params[:query])

    redirect_to book if book.present?
  end

  def request_description
    return if @book.listings.where.not(description: nil).none?
    return if @book.description_last_generated_at.present?

    puts "Requested new description"

    RequestDescriptionJob.perform_later(@book.isbn)
  end

  def request_cover
    return if @book.cover_image.attached?
    return if @book.cover_last_scraped_at.present?

    puts "Requested new cover"

    RequestCoverJob.perform_later(@book.isbn)
  end
end

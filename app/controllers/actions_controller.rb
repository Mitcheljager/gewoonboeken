class ActionsController < ApplicationController
  before_action :redirect_unless_admin

  def index_by_isbn
    begin
      output = `ruby #{Rails.root.join("scraper/index/index_book_by_isbn.rb")} #{params[:isbn]}`
      Rails.logger.info output

      @book = Book.find_by_isbn(params[:isbn])
      redirect_to [:admin, @book], notice: "Book was successfully updated.", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to root_path, status: :unprocessable_entity
    end
  end

  def attach_image_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      RequestCoverJob.new.perform(@book.isbn, force: true)

      raise "No image was attached" unless @book.cover_image.attached?

      redirect_to [:admin, @book], notice: "Image was successfully attached", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to [:admin, @book], status: :unprocessable_entity
    end
  end

  def run_all_scrapers_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      RequestScrapeJob.new.perform(@book.isbn, force: true)

      redirect_to [:admin, @book], notice: "Scrapers completed successfully", status: :see_other
    rescue => error
      puts error
      flash[:alert] = error
      redirect_to [:admin, @book]
    end
  end

  def generate_ai_description_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      RequestDescriptionJob.new.perform(@book.isbn, force: true)

      redirect_to [:admin, @book], notice: "AI completed successfully", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to [:admin, @book], status: :unprocessable_entity
    end
  end

  def generate_ai_keywords_for_isbn
    @book = Book.find_by_isbn!(params[:isbn])

    begin
      output = `ruby #{Rails.root.join("scraper/ai/openai_keywords.rb")} isbn=#{@book.isbn}`
      Rails.logger.info output

      redirect_to [:admin, @book], notice: "AI completed successfully", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to [:admin, @book], status: :unprocessable_entity
    end
  end

  def generate_ai_description_for_author
    @author = Author.find_by_slug!(params[:slug])

    begin
      output = `ruby #{Rails.root.join("scraper/ai/openai_author_description.rb")} "#{@author.name}"`
      Rails.logger.info output

      redirect_to [:admin, @author], notice: "AI completed successfully", status: :see_other
    rescue => error
      flash[:alert] = error
      redirect_to [:admin, @author], status: :unprocessable_entity
    end
  end
end

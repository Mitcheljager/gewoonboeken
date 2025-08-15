class SitemapsController < ApplicationController
  def sitemap
    @genres = Genre.select(:name, :slug)
    @books = Book.select(:title, :isbn, :updated_at)

    respond_to do |format|
      format.xml
    end
  end
end

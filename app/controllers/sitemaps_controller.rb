class SitemapsController < ApplicationController
  def sitemap
    @genres = Genre.select(:id, :name, :slug, :updated_at)
    @books = Book.select(:id, :title, :isbn, :updated_at)

    respond_to do |format|
      format.xml
    end
  end
end

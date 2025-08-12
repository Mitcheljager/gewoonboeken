class GenresController < ApplicationController
  before_action :set_genre, only: [:show]

  def show
    @hot_books = @genre.books.overview_join.includes(:authors, :listings).order(hotness: :desc).limit(8)
    @subgenres = @genre.subgenres.order(books_count: :desc).limit(4)
  end

  private

  def set_genre
    @genre = Genre.find_by_slug!(params.expect(:slug))
  end
end

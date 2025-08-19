class PagesController < ApplicationController
  def index
    @genres = Genre.where.not(books_count: 0).order(name: :asc)
    @hot_books = Book.overview_join.order(hotness: :desc).limit(8)
    @mystery_books = Genre.find_by_slug("mysterie").books.overview_join.order(hotness: :desc).limit(8)
    @fantasy_books = Genre.find_by_slug("fantasy").books.overview_join.order(hotness: :desc).limit(8)
    @cook_books = Genre.find_by_slug("kookboeken").books.overview_join.order(hotness: :desc).limit(8)
  end

  def about
  end

  def privacy
  end

  def affiliate
  end
end

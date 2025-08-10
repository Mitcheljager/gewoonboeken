class PagesController < ApplicationController
  def index
    @hot_books = Book.full_join.order(hotness: :desc).limit(8)
    @mystery_books = Genre.find_by_slug("mysterie").books.full_join.order(hotness: :desc).limit(8)
    @fantasy_books = Genre.find_by_slug("fantasy").books.full_join.order(hotness: :desc).limit(8)
    @cook_books = Genre.find_by_slug("kookboeken").books.full_join.order(hotness: :desc).limit(8)
  end

  def about
  end

  def privacy
  end
end

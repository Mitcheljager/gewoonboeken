class Api::BooksController < Api::BaseController
  def isbn_list
    books = Book.all.order(hotness: :desc).select(:isbn).pluck(:isbn)

    render json: books
  end
end

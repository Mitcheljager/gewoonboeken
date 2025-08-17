class Api::BooksController < Api::BaseController
  def isbn_list
    order = params[:order] || "hotness"
    order_direction = params[:order_direction] || "desc"

    books = Book.all.order("#{order} #{order_direction}").select(:isbn).pluck(:isbn)

    render json: books
  end
end

class Api::BooksController < Api::BaseController
  def isbn_list
    order = params[:order] || "hotness"
    order_direction = params[:order_direction] || "desc"
    offset = params[:offset] || 0

    books = Book.all.order("#{order} #{order_direction}").offset(offset).select(:isbn).pluck(:isbn)

    render json: books
  end
end

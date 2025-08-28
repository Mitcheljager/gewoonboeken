require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:book_one)
  end

  test "Should get index" do
    get books_url

    assert_response :success
    assert_select "h1", "Alle boeken"
  end

  test "Should redirect to book when ISBN query matches" do
    get books_url(query: @book.isbn)

    assert_redirected_to book_url(@book)
  end

  test "Should not redirect when query is not ISBN" do
    get books_url(query: "Some query")

    assert_response :success
  end

  test "Should show book" do
    get book_url(@book)

    assert_response :success
    assert_select "h1", @book.title
  end
end

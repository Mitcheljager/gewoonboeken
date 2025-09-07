require "test_helper"

class Api::BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book_one = books(:book_one)
    @book_two = books(:book_two)

    @token = "some-token"
    ENV["INTERNAL_API_TOKEN"] = @token
  end

  test "Returns list of isbns in default order" do
    get api_isbn_list_url, headers: { "Token" => @token }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_includes body, @book_one.isbn
    assert_includes body, @book_two.isbn
  end

  test "Respects order and order_direction params" do
    get api_isbn_list_url(order: "hotness", order_direction: "asc"), headers: { "Token" => @token }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal [@book_one.isbn, @book_two.isbn], body
  end

  test "Applies offset param" do
    get api_isbn_list_url(order: "hotness", offset: 1), headers: { "Token" => @token }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal [@book_one.isbn], body
  end

  test "Returns empty array if offset is too high" do
    get api_isbn_list_url(offset: 99), headers: { "Token" => @token }, as: :json
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal [], body
  end
end

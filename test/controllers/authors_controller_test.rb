require "test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = authors(:author_one)
    @book = books(:book_one)
    @book_other_author = books(:book_two)
  end

  test "shows author and their books" do
    get author_path(@author.slug)

    assert_response :success
    assert_select "h1", /Boeken door #{@author.name}/
    assert_select ".cards .card", text: /#{@book.title}/
    assert_select ".cards .card", text: /#{@book_other_author.title}/, count: 0
  end

  test "Should return 404 author is not found" do
    get author_path("no-author")

    assert_response :not_found
  end
end

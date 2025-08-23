require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "Should get index" do
    @mystery   = genres(:genre_five)
    @fantasy   = genres(:genre_four)
    @cookbooks = genres(:genre_six)

    @book1 = books(:book_one)
    @book2 = books(:book_two)

    BookGenre.create!(book: @book1, genre: @fantasy)
    BookGenre.create!(book: @book2, genre: @cookbooks)

    get root_url
    assert_response :success

    assert_includes @response.body, @book1.title
    assert_includes @response.body, @book2.title
  end

  test "Should get about" do
    get about_url
    assert_response :success
  end

  test "Should get privacy" do
    get privacy_url
    assert_response :success
  end

  test "Should get affiliate" do
    get affiliate_url
    assert_response :success
  end
end

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

  test "Should render correct hero image for dark theme" do
    cookies[:theme] = "dark"
    get root_url

    assert_select "img[src*='doodle-reader-dark.png']"
    assert_select "source[srcset*='doodle-reader']", count: 0
    assert_select "source[data-srcset*='doodle-reader']", count: 2
  end

  test "Should render correct hero image for light theme" do
    cookies[:theme] = "light"
    get root_url

    assert_select "img[src*='doodle-reader-light']"
    assert_select "source[srcset*='doodle-reader']", count: 0
    assert_select "source[data-srcset*='doodle-reader']", count: 2
  end

  test "Should render correct hero image with srcset in source when no theme is set via cookie" do
    cookies[:theme] = nil
    get root_url

    assert_select "source[srcset*='doodle-reader']", count: 2
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

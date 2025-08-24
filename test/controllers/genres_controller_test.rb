require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genre = genres(:genre_one)
    @book = books(:book_one)
    @other_book = books(:book_two)
    @subgenre = genres(:genre_three)
  end

  test "Shows genre page with hot books and subgenres" do
    get genre_path(@genre.slug)

    assert_response :success

    assert_select "h1", @genre.name
    assert_select ".cards .card", text: /#{@book.title}/
    assert_select ".cards .card", text: /#{@other_book.title}/, count: 0

    assert_select "nav.tags a", text: @subgenre.name
    assert_select "h2", @subgenre.name
  end

  test "Should not show subgenres if none are found" do
    get genre_path(@subgenre.slug)

    assert_response :success

    assert_select "h1", @subgenre.name
    assert_select "nav.tags", count: 0
  end

  test "Returns 404 if genre not found" do
    get genre_path("no-genre")

    assert_response :not_found
  end
end

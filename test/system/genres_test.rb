require "application_system_test_case"

class GenresTest < ApplicationSystemTestCase
  setup do
    @genre = genres(:one)
  end

  test "visiting the index" do
    visit genres_url
    assert_selector "h1", text: "Genres"
  end

  test "should create genre" do
    visit genres_url
    click_on "New genre"

    fill_in "Keywords", with: @genre.keywords
    fill_in "Name", with: @genre.name
    fill_in "Parent genre", with: @genre.parent_genre_id
    click_on "Create Genre"

    assert_text "Genre was successfully created"
    click_on "Back"
  end

  test "should update Genre" do
    visit genre_url(@genre)
    click_on "Edit this genre", match: :first

    fill_in "Keywords", with: @genre.keywords
    fill_in "Name", with: @genre.name
    fill_in "Parent genre", with: @genre.parent_genre_id
    click_on "Update Genre"

    assert_text "Genre was successfully updated"
    click_on "Back"
  end

  test "should destroy Genre" do
    visit genre_url(@genre)
    click_on "Destroy this genre", match: :first

    assert_text "Genre was successfully destroyed"
  end
end

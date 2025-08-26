require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book_one  = books(:book_one)
    @book_two  = books(:book_two)

    @genre_one = genres(:genre_one)
    @genre_two = genres(:genre_two)
  end

  test "Returns a sitemap with given data" do
    get sitemap_url(format: :xml)

    assert_response :success
    assert_equal @response.media_type, "application/xml"

    assert_includes @response.body, root_url
    assert_includes @response.body, about_url

    assert_includes @response.body, book_url(@book_one)
    assert_includes @response.body, book_url(@book_two)

    assert_includes @response.body, genre_url(@genre_one)
    assert_includes @response.body, genre_url(@genre_two)
  end

  test "Contains lastmod" do
    get sitemap_url(format: :xml)

    assert_match @book_one.updated_at.iso8601, @response.body
    assert_match @genre_one.updated_at.iso8601, @response.body
  end
end
